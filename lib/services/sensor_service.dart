import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  Stream<double> get vibrationStream {
    return accelerometerEventStream().map((AccelerometerEvent event) {
      // Combined magnitude: sqrt(x^2 + y^2 + z^2)
      // Minus gravity (approx 9.81) to get the actual vibration
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      double vibration = (magnitude - 9.81).abs();
      return vibration;
    });
  }
}
