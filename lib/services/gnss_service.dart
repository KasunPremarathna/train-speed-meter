import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GnssService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.sl_train_monitor/gnss',
  );

  Stream<Map<String, int>> get satelliteStream async* {
    while (true) {
      try {
        final dynamic result = await _channel.invokeMethod('getGnssStatus');
        if (result != null) {
          yield {
            'inView': result['inView'] as int,
            'usedInFix': result['usedInFix'] as int,
          };
        }
      } on PlatformException catch (e) {
        debugPrint("Failed to get GNSS status: '${e.message}'.");
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
