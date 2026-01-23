import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/station.dart';
import '../services/gps_service.dart';
import '../services/ad_service.dart';
import '../services/settings_service.dart';

class FullMapScreen extends StatefulWidget {
  const FullMapScreen({super.key});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  final GpsService _gpsService = GpsService();
  final MapController _mapController = MapController();
  final SettingsService _settings = SettingsService();

  Position? _currentPosition;
  List<Station> _stations = [];
  late bool _autoCenter;
  bool? _lastAutoFollowSetting;
  StreamSubscription? _posSub;

  @override
  void initState() {
    super.initState();
    _autoCenter = _settings.autoFollowLocation;
    AdService().showInterstitialAd();
    _loadStations();
    _initGPS();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
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

  void _initGPS() async {
    bool hasPermission = await _gpsService.handlePermission();
    if (!hasPermission) return;

    _posSub = _gpsService.positionStream.listen((pos) {
      setState(() {
        _currentPosition = pos;
        if (_autoCenter) {
          _mapController.move(
            LatLng(pos.latitude, pos.longitude),
            _mapController.camera.zoom,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sync auto-center with settings ONLY if the setting has changed
    if (_lastAutoFollowSetting != _settings.autoFollowLocation) {
      _autoCenter = _settings.autoFollowLocation;
      _lastAutoFollowSetting = _settings.autoFollowLocation;
    }
    LatLng center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(6.9344, 79.8501);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'FULL MAP VIEW',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
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
                  heroTag: 'zoom_in_full',
                  backgroundColor: const Color(0xFF1E1E1E),
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out_full',
                  backgroundColor: const Color(0xFF1E1E1E),
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'my_location_full',
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
    );
  }
}
