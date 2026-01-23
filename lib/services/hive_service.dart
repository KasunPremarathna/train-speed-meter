import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String boxName = 'settingsBox';
  late Box _box;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
    _isInitialized = true;
  }

  Future<void> saveSetting(String key, dynamic value) async {
    await _box.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }
}
