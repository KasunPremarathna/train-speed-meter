import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();

  late bool _autoFollow;
  late bool _showStations;
  late bool _showLines;
  late double _zoomLevel;

  @override
  void initState() {
    super.initState();
    _autoFollow = _settings.autoFollowLocation;
    _showStations = _settings.showStationMarkers;
    _showLines = _settings.showRailwayLines;
    _zoomLevel = _settings.mapZoomLevel;
  }

  Future<void> _saveAllSettings() async {
    await _settings.setAutoFollow(_autoFollow);
    await _settings.setShowStations(_showStations);
    await _settings.setShowRailwayLines(_showLines);
    await _settings.setZoomLevel(_zoomLevel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
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
          TextButton.icon(
            onPressed: _saveAllSettings,
            icon: const Icon(Icons.save, color: Colors.blueAccent),
            label: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('MAP SETTINGS'),
          _buildSettingCard(
            title: 'Auto-Follow Location',
            subtitle: 'Keep map centered on your location',
            value: _autoFollow,
            onChanged: (value) {
              setState(() => _autoFollow = value);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            title: 'Show Station Markers',
            subtitle: 'Display railway stations on map',
            value: _showStations,
            onChanged: (value) {
              setState(() => _showStations = value);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            title: 'Show Railway Lines',
            subtitle: 'Display railway track lines',
            value: _showLines,
            onChanged: (value) {
              setState(() => _showLines = value);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('DISPLAY'),
          _buildSliderCard(
            title: 'Default Map Zoom',
            subtitle: 'Initial zoom level: ${_zoomLevel.toStringAsFixed(1)}',
            value: _zoomLevel,
            min: 10.0,
            max: 18.0,
            onChanged: (value) {
              setState(() => _zoomLevel = value);
            },
          ),
          const SizedBox(height: 12),
          _buildInfoCard(title: 'Total Stations', value: '81'),
          const SizedBox(height: 12),
          _buildInfoCard(title: 'Railway Lines', value: '9'),
          const SizedBox(height: 24),
          _buildSectionHeader('NOTIFICATIONS'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Receive real-time alerts and updates',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await NotificationService().requestPermission();
                    if (mounted) setState(() {});
                  },
                  child: Text(
                    NotificationService().isPermissionGranted
                        ? 'ENABLED'
                        : 'ENABLE',
                    style: TextStyle(
                      color: NotificationService().isPermissionGranted
                          ? Colors.greenAccent
                          : Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('DEBUGGING'),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Reloading Ads...')));
              AdService().loadInterstitialAd();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reload Ads'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAllSettings,
        label: const Text('SAVE SETTINGS'),
        icon: const Icon(Icons.save),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: value
              ? Colors.blueAccent.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 2).toInt(),
            activeColor: Colors.blueAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
