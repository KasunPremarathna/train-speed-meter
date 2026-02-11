import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../main_navigation.dart';
import 'location_disclosure_screen.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) async {
    await SettingsService().completeOnboarding();
    if (context.mounted) {
      final settings = SettingsService();
      final nextScreen = settings.locationConsentAccepted == null
          ? const LocationDisclosureScreen()
          : const MainNavigation();

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
    }
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyTextStyle: TextStyle(fontSize: 18.0, color: Colors.white70),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color(0xFF121212),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      globalBackgroundColor: const Color(0xFF121212),
      pages: [
        PageViewModel(
          title: "Real-time Speed",
          body:
              "Monitor your train's speed in KMPH with high-precision GPS tracking and smoothing.",
          image: _buildImage(Icons.speed, Colors.blueAccent),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Live Train Map",
          body:
              "Track your exact location on the map with all Sri Lankan railway stations and lines visible.",
          image: _buildImage(Icons.map, Colors.greenAccent),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Never Miss a Stop",
          body:
              "See the nearest and next stations with real-time distance calculations as you travel.",
          image: _buildImage(Icons.add_location, Colors.orangeAccent),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Smart Persistence",
          body:
              "Your personalized map settings and preferences are saved securely on your device.",
          image: _buildImage(Icons.settings, Colors.purpleAccent),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Stay Updated",
          body:
              "Allow notifications to receive real-time updates and important alerts during your journey.",
          image: _buildImage(Icons.notifications_active, Colors.redAccent),
          footer: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: ElevatedButton(
              onPressed: () => NotificationService().requestPermission(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Allow Notifications"),
            ),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.white24,
        activeColor: Colors.blueAccent,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

  Widget _buildImage(IconData icon, Color color) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 100),
      ),
    );
  }
}
