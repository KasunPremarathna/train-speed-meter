import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/gps_service.dart';
import '../main_navigation.dart';

class LocationDisclosureScreen extends StatelessWidget {
  const LocationDisclosureScreen({super.key});

  Future<void> _handleAccept(BuildContext context) async {
    await SettingsService().setLocationConsent(true);

    // Request permission immediately after acceptance
    final gpsService = GpsService();
    await gpsService.handlePermission();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  Future<void> _handleDecline(BuildContext context) async {
    await SettingsService().setLocationConsent(false);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.blueAccent, size: 64),
              const SizedBox(height: 32),
              const Text(
                "Prominent Disclosure: Location Data",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBulletPoint(
                        "What is collected?",
                        "This app accesses your device's precise location (GPS) data.",
                      ),
                      _buildBulletPoint(
                        "Why is it needed?",
                        "Your location is used to calculate real-time train speed and to show your current position on the railway map while you travel.",
                      ),
                      _buildBulletPoint(
                        "Data Privacy",
                        "Your location data is processed only on your device. It is NOT stored on any server and is NOT shared with any third parties.",
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "This app operates better with location access. You can grant permission in the next step after accepting this disclosure.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleAccept(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Accept & Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _handleDecline(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "No Thanks",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
