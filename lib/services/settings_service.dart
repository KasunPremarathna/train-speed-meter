import 'hive_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final HiveService _hive = HiveService();

  // Keys
  static const String keyAutoFollow = 'autoFollowLocation';
  static const String keyShowStations = 'showStationMarkers';
  static const String keyShowRailwayLines = 'showRailwayLines';
  static const String keyZoomLevel = 'mapZoomLevel';
  static const String keyIsFirstTime = 'isFirstTime';
  static const String keyLocationConsent = 'locationConsentAccepted';

  // State
  bool autoFollowLocation = true;
  bool showStationMarkers = true;
  bool showRailwayLines = true;
  double mapZoomLevel = 13.0;
  bool isFirstTime = true;
  bool?
  locationConsentAccepted; // null means not yet decided, false means declined, true means accepted

  Future<void> initialize() async {
    await _hive.initialize();
    autoFollowLocation = _hive.getSetting(keyAutoFollow, defaultValue: true);
    showStationMarkers = _hive.getSetting(keyShowStations, defaultValue: true);
    showRailwayLines = _hive.getSetting(
      keyShowRailwayLines,
      defaultValue: true,
    );
    mapZoomLevel = _hive.getSetting(keyZoomLevel, defaultValue: 13.0);
    isFirstTime = _hive.getSetting(keyIsFirstTime, defaultValue: true);
    locationConsentAccepted = _hive.getSetting(
      keyLocationConsent,
      defaultValue: null,
    );
  }

  Future<void> completeOnboarding() async {
    isFirstTime = false;
    await _hive.saveSetting(keyIsFirstTime, false);
  }

  Future<void> setAutoFollow(bool value) async {
    autoFollowLocation = value;
    await _hive.saveSetting(keyAutoFollow, value);
  }

  Future<void> setShowStations(bool value) async {
    showStationMarkers = value;
    await _hive.saveSetting(keyShowStations, value);
  }

  Future<void> setShowRailwayLines(bool value) async {
    showRailwayLines = value;
    await _hive.saveSetting(keyShowRailwayLines, value);
  }

  Future<void> setZoomLevel(double value) async {
    mapZoomLevel = value;
    await _hive.saveSetting(keyZoomLevel, value);
  }

  Future<void> setLocationConsent(bool value) async {
    locationConsentAccepted = value;
    await _hive.saveSetting(keyLocationConsent, value);
  }
}
