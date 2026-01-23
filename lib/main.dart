import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'screens/onboarding_screen.dart';
import 'services/ad_service.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().initialize();
  await AdService().initialize();
  await NotificationService().initialize();
  runApp(const TrainMonitorApp());
}

class TrainMonitorApp extends StatelessWidget {
  const TrainMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Train Speed Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: SettingsService().isFirstTime
          ? const OnboardingScreen()
          : const MainNavigation(),
    );
  }
}
