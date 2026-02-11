import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/station.dart';
import '../services/gps_service.dart';
import '../services/sensor_service.dart';
import '../services/gnss_service.dart';
import './full_map_screen.dart';
import '../services/settings_service.dart';
import './settings_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GpsService _gpsService = GpsService();
  final SensorService _sensorService = SensorService();
  final GnssService _gnssService = GnssService();
  final SettingsService _settings = SettingsService();

  Position? _currentPosition;
  double _speed = 0.0;
  double _smoothedSpeed = 0.0; // For exponential moving average
  double _accuracy = 0.0;
  static const double _speedSmoothingFactor = 0.3; // Lower = smoother
  int _satsInView = 0;
  int _satsUsed = 0;
  List<Station> _stations = [];
  Station? _nearestStation;
  Station? _nextStation;
  double _distanceToNext = 0.0;

  final List<FlSpot> _vibrationData = [];
  double _vibrationMagnitude = 0.0;
  int _timerCount = 0;
  late bool _autoCenter;
  bool? _lastAutoFollowSetting;

  StreamSubscription? _posSub;
  StreamSubscription? _vibSub;
  StreamSubscription? _gnssSub;

  final MapController _mapController = MapController();

  // Trip Summary Data
  double _maxSpeed = 0.0;
  double _maxVibration = 0.0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _autoCenter = _settings.autoFollowLocation;
    _startTime = DateTime.now();
    _loadStations();
    _initServices();
  }

  Future<void> _loadStations() async {
    final String response = await rootBundle.loadString(
      'assets/data/stations.json',
    );
    final List<dynamic> data = json.decode(response);
    setState(() {
      _stations = data.map((json) => Station.fromJson(json)).toList();
    });
  }

  void _initServices() async {
    if (_settings.locationConsentAccepted != true) return;
    bool hasPermission = await _gpsService.handlePermission();
    if (!hasPermission) return;

    _posSub = _gpsService.positionStream.listen((pos) {
      setState(() {
        _currentPosition = pos;

        // Convert m/s to km/h
        double rawSpeed = pos.speed * 3.6;

        // Apply speed threshold to filter GPS drift
        // If speed is below 0.2 km/h or accuracy is poor (>10m when stationary), treat as stationary
        if (rawSpeed < 0.2 || (rawSpeed < 1.0 && pos.accuracy > 10)) {
          rawSpeed = 0.0;
        }

        // Apply exponential moving average for smooth speed transitions
        _smoothedSpeed =
            (_speedSmoothingFactor * rawSpeed) +
            ((1 - _speedSmoothingFactor) * _smoothedSpeed);
        _speed = _smoothedSpeed;

        if (_speed > _maxSpeed) _maxSpeed = _speed;
        _accuracy = pos.accuracy;
        _detectStations(pos);

        if (_autoCenter) {
          _mapController.move(
            LatLng(pos.latitude, pos.longitude),
            _mapController.camera.zoom,
          );
        }
      });
    });

    _vibSub = _sensorService.vibrationStream.listen((vib) {
      setState(() {
        _vibrationMagnitude = vib;
        if (vib > _maxVibration) _maxVibration = vib;
        _vibrationData.add(FlSpot(_timerCount.toDouble(), vib));
        if (_vibrationData.length > 50) _vibrationData.removeAt(0);
        _timerCount++;
      });
    });

    _gnssSub = _gnssService.satelliteStream.listen((gnss) {
      setState(() {
        _satsInView = gnss['inView'] ?? 0;
        _satsUsed = gnss['usedInFix'] ?? 0;
      });
    });
  }

  void _detectStations(Position pos) {
    if (_stations.isEmpty) return;

    // Calculate distances for all stations based on GPS position
    List<MapEntry<Station, double>> stationsWithDistance = _stations.map((s) {
      double d = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        s.lat,
        s.lng,
      );
      return MapEntry(s, d);
    }).toList();

    // Sort by distance - nearest first
    stationsWithDistance.sort((a, b) => a.value.compareTo(b.value));

    // Always use the nearest station by GPS distance
    Station nearest = stationsWithDistance.first.key;

    int nearestIndex = _stations.indexOf(nearest);
    Station? next;
    if (nearestIndex < _stations.length - 1) {
      next = _stations[nearestIndex + 1];
    } else {
      next = _stations[0];
    }

    double distToNext =
        Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          next.lat,
          next.lng,
        ) /
        1000.0;

    setState(() {
      _nearestStation = nearest;
      _nextStation = next;
      _distanceToNext = distToNext;
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _vibSub?.cancel();
    _gnssSub?.cancel();
    super.dispose();
  }

  Color _getVibrationColor(double val) {
    if (val < 0.5) return Colors.greenAccent;
    if (val < 1.5) return Colors.yellowAccent;
    if (val < 3.0) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getVibrationIntensity(double val) {
    if (val < 0.5) return 'SMOOTH';
    if (val < 1.5) return 'MODERATE';
    if (val < 3.0) return 'STRONG';
    return 'ROUGH';
  }

  @override
  Widget build(BuildContext context) {
    // Sync auto-center with settings ONLY if the setting has changed
    if (_lastAutoFollowSetting != _settings.autoFollowLocation) {
      _autoCenter = _settings.autoFollowLocation;
      _lastAutoFollowSetting = _settings.autoFollowLocation;
    }
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'TRAIN SPEED MONITOR',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blueAccent),
            onPressed: () {
              setState(() {
                _maxSpeed = 0;
                _maxVibration = 0;
                _startTime = DateTime.now();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.summarize, color: Colors.blueAccent),
            onPressed: _showTripSummary,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                if (_settings.locationConsentAccepted == false)
                  _buildNoLocationBanner(),
                _buildTopStatsBar(),
                const SizedBox(height: 12),
                _buildSpeedometer(),
                const SizedBox(height: 12),
                SizedBox(height: 200, child: _buildVibrationGraph()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildGnssPanel()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccuracyPanel()),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStationPanel(),
                const SizedBox(height: 12),
                SizedBox(height: 400, child: _buildMap()),
                const SizedBox(height: 16),
                // const Center(child: BannerAdWidget()), // Temporarily disabled
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildNoLocationBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Location required for live speed. Enable in Settings.",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: const Text("Settings"),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatsBar() {
    return Row(
      children: [
        Expanded(
          child: _statIndicator(
            'PEAK SPEED',
            _maxSpeed.toStringAsFixed(1),
            'km/h',
            Colors.redAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statIndicator(
            'PEAK VIB',
            _maxVibration.toStringAsFixed(2),
            'g',
            Colors.orangeAccent,
          ),
        ),
      ],
    );
  }

  Widget _statIndicator(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 8,
              letterSpacing: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedometer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              const Text(
                'SPEED',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              Text(
                _speed.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const Text(
                'km/h',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getVibrationIntensity(_vibrationMagnitude),
                  style: TextStyle(
                    color: _getVibrationColor(_vibrationMagnitude),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _vibrationMagnitude.toStringAsFixed(2),
                  style: TextStyle(
                    color: _getVibrationColor(_vibrationMagnitude),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'MAG (g)',
                  style: TextStyle(
                    color: _getVibrationColor(
                      _vibrationMagnitude,
                    ).withValues(alpha: 0.6),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGnssPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.satellite_alt, color: Colors.orangeAccent, size: 20),
          const SizedBox(height: 4),
          const Text(
            'SATELLITES',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          Row(
            children: [
              Text(
                '$_satsUsed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / $_satsInView',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gps_fixed, color: Colors.greenAccent, size: 20),
          const SizedBox(height: 4),
          const Text(
            'ACCURACY',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          Text(
            '${_accuracy.toStringAsFixed(1)} m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT',
                      style: TextStyle(color: Colors.grey, fontSize: 8),
                    ),
                    Text(
                      _nearestStation?.name ?? 'Detecting...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_nearestStation != null)
                      Text(
                        '[${_nearestStation!.code}] ${_nearestStation!.type} • ${_nearestStation!.line}',
                        style: const TextStyle(color: Colors.grey, fontSize: 9),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white10, height: 1),
          ),
          Row(
            children: [
              const Icon(Icons.next_plan, color: Colors.blueAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEXT',
                      style: TextStyle(color: Colors.grey, fontSize: 8),
                    ),
                    Text(
                      _nextStation?.name ?? '--',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_nextStation != null)
                      Text(
                        '[${_nextStation!.code}] ${_nextStation!.type} • ${_nextStation!.line}',
                        style: const TextStyle(color: Colors.grey, fontSize: 9),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'DIST',
                    style: TextStyle(color: Colors.grey, fontSize: 8),
                  ),
                  Text(
                    '${_distanceToNext.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    LatLng center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(6.9344, 79.8501);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FullMapScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13.0,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    setState(() => _autoCenter = false);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kasunpremarathna.sl_train_monitor',
                ),
                if (_settings.showRailwayLines)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _stations
                            .map((s) => LatLng(s.lat, s.lng))
                            .toList(),
                        color: Colors.blueAccent,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        point: center,
                        width: 48,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.train,
                            color: Colors.blueAccent,
                            size: 28,
                          ),
                        ),
                      ),
                    if (_settings.showStationMarkers)
                      ..._stations.map(
                        (s) => Marker(
                          point: LatLng(s.lat, s.lng),
                          width: 8,
                          height: 8,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    backgroundColor: const Color(0xFF1E1E1E),
                    onPressed: () {
                      final zoom = _mapController.camera.zoom;
                      _mapController.move(
                        _mapController.camera.center,
                        zoom + 1,
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    backgroundColor: const Color(0xFF1E1E1E),
                    onPressed: () {
                      final zoom = _mapController.camera.zoom;
                      _mapController.move(
                        _mapController.camera.center,
                        zoom - 1,
                      );
                    },
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'my_location',
                    backgroundColor: Colors.blueAccent,
                    onPressed: () {
                      if (_currentPosition != null) {
                        setState(() => _autoCenter = true);
                        _mapController.move(
                          LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          15.0,
                        );
                      }
                    },
                    child: Icon(
                      Icons.my_location,
                      color: _autoCenter ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibrationGraph() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRAIN LIVE VIBRATION',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 4,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _vibrationData,
                    isCurved: true,
                    color: _getVibrationColor(_vibrationMagnitude),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _getVibrationColor(
                            _vibrationMagnitude,
                          ).withValues(alpha: 0.2),
                          _getVibrationColor(
                            _vibrationMagnitude,
                          ).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTripSummary() {
    final duration = DateTime.now().difference(_startTime!);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TRIP SUMMARY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _summaryItem(
                'Peak Speed',
                '${_maxSpeed.toStringAsFixed(1)} km/h',
                Icons.speed,
                Colors.redAccent,
              ),
              _summaryItem(
                'Peak Vibration',
                '${_maxVibration.toStringAsFixed(2)} g',
                Icons.vibration,
                Colors.orangeAccent,
              ),
              _summaryItem(
                'Duration',
                '${duration.inMinutes} mins',
                Icons.timer,
                Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
