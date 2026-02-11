import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Replace with your OneSignal App ID
  static const String _appId = "0ccb3cb2-5358-4317-bfac-fd45b45b5248";

  Future<void> initialize() async {
    print('NotificationService: Initializing OneSignal...');

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

  Future<void> requestPermission() async {
    try {
      await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      print('NotificationService: Error requesting permission: $e');
    }
  }

  bool get isPermissionGranted => OneSignal.Notifications.permission;
}
