import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class SensorService {
  static SensorService? _instance;
  static SensorService get instance => _instance ??= SensorService._();
  
  SensorService._();

  Stream<bool>? _shakeStream;
  
  Stream<bool> get shakeDetection {
    _shakeStream ??= accelerometerEventStream().map((event) {
      // Calculate the magnitude of acceleration
      double magnitude = sqrt(
        event.x * event.x + 
        event.y * event.y + 
        event.z * event.z
      );
      
      // Detect shake if magnitude exceeds threshold (typically 12-15)
      return magnitude > 12.0;
    }).distinct(); // Only emit when shake state changes
    
    return _shakeStream!;
  }

  void dispose() {
    _shakeStream = null;
  }
}