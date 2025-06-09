import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class Constants {
  // Fallback muscle groups yang sudah teruji ada exercise-nya
  static const List<String> _fallbackMuscleGroups = [
    'biceps',
    'triceps', 
    'chest',
    'upper back',
    'lower back',
    'abs',
    'glutes',
    'quadriceps',
    'hamstrings', 
    'calves',
    'shoulders',
    'forearms'
  ];

  // Get muscle groups yang benar-benar ada exercise-nya
  static Future<List<String>> getMuscleGroups() async {
    try {
      return await ApiService.getAvailableMuscles();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Using fallback muscle groups due to error: $e');
      }
      return _fallbackMuscleGroups;
    }
  }

  // Get muscle statistics
  static Future<Map<String, int>> getMuscleStatistics() async {
    try {
      return await ApiService.getMuscleStatistics();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting muscle statistics: $e');
      }
      return {};
    }
  }

  // Synchronous fallback untuk UI yang memerlukan immediate access
  static List<String> get muscleGroups => _fallbackMuscleGroups;

  static const List<String> bodyParts = [
    'upper arms',
    'back',
    'waist',
    'upper legs', 
    'lower legs',
    'shoulders',
    'chest',
    'neck'
  ];

  static const List<String> equipments = [
    'body weight',
    'dumbbell',
    'barbell', 
    'cable',
    'machine',
    'resistance band',
    'kettlebell',
    'olympic barbell',
    'ez barbell'
  ];

  static const List<String> currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'IDR', 'SGD', 'MYR', 'THB', 'AUD', 'CAD'
  ];

  static const List<String> timezones = [
    'Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura', 'Europe/London',
    'Europe/Amsterdam', 'America/New_York', 'Asia/Tokyo', 'Asia/Singapore',
    'Australia/Sydney', 'America/Los_Angeles', 'Europe/Paris', 'Asia/Dubai'
  ];

  static const Map<String, String> timezoneDisplayNames = {
    'Asia/Jakarta': 'WIB (Jakarta)',
    'Asia/Makassar': 'WITA (Makassar)',
    'Asia/Jayapura': 'WIT (Jayapura)', 
    'Europe/London': 'GMT (London)',
    'Europe/Amsterdam': 'CET (Amsterdam)',
    'America/New_York': 'EST (New York)',
    'Asia/Tokyo': 'JST (Tokyo)',
    'Asia/Singapore': 'SGT (Singapore)',
    'Australia/Sydney': 'AEDT (Sydney)',
    'America/Los_Angeles': 'PST (Los Angeles)',
    'Europe/Paris': 'CET (Paris)',
    'Asia/Dubai': 'GST (Dubai)',
  };
}