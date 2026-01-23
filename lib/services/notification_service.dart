import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Replace with your OneSignal App ID
  static const String _appId = "YOUR_ONESIGNAL_APP_ID_HERE";

  Future<void> initialize() async {
    print('NotificationService: Initializing OneSignal...');

    // Remove this check if you have a real App ID
    if (_appId == "0ccb3cb2-5358-4317-bfac-fd45b45b5248") {
      print(
        'NotificationService: Skipping initialization - placeholder App ID used.',
      );
      return;
    }

    try {
      // OneSignal initialization
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(_appId);

      // Request permissions
      OneSignal.Notifications.requestPermission(true);

      print('NotificationService: OneSignal initialized successfully.');
    } catch (e) {
      print('NotificationService: Initialization error: $e');
    }
  }
}
