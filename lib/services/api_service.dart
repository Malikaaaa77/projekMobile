import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';

class ApiService {
  // Exercise API - HANYA INI YANG DIGUNAKAN
  static const String exerciseBaseUrl = 'https://exercisedb-api.vercel.app/api/v1';

  // Cache untuk menyimpan data
  static List<ExerciseModel>? _allExercisesCache;
  static List<String>? _availableMusclesCache;
  static Map<String, int>? _muscleStatsCache;
  static DateTime? _cacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 30);

  // Muscle mapping berdasarkan API real data
  static const Map<String, List<String>> muscleMapping = {
    'biceps': ['biceps', 'biceps brachii'],
    'triceps': ['triceps', 'triceps brachii'],
    'chest': ['chest', 'pectorals', 'pectoralis major', 'pectoralis minor'],
    'back': ['back', 'upper back', 'lower back', 'latissimus dorsi', 'rhomboids', 'lats'],
    'shoulders': ['shoulders', 'deltoids', 'anterior deltoid', 'posterior deltoid', 'lateral deltoid', 'delts'],
    'abs': ['abs', 'abdominals', 'core', 'rectus abdominis'],
    'glutes': ['glutes', 'gluteus maximus', 'gluteus medius', 'gluteus minimus'],
    'quadriceps': ['quadriceps', 'quads', 'vastus lateralis', 'vastus medialis', 'rectus femoris'],
    'hamstrings': ['hamstrings', 'biceps femoris', 'semitendinosus', 'semimembranosus'],
    'calves': ['calves', 'gastrocnemius', 'soleus', 'calf'],
    'forearms': ['forearms', 'wrist flexors', 'wrist extensors'],
    'traps': ['traps', 'trapezius'],
  };

  /// **CORE FUNCTION: Get All Exercises dari ExerciseDB API**
  static Future<List<ExerciseModel>> getAllExercises({int limit = 50}) async {
    // Check cache first
    if (_allExercisesCache != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheTimeout) {
      return _allExercisesCache!;
    }

    try {
      List<ExerciseModel> allExercises = [];
      int offset = 0;
      bool hasMore = true;
      int maxPages = 8;
      int currentPage = 0;
      
      while (hasMore && currentPage < maxPages) {
        if (kDebugMode) {
          debugPrint('Fetching exercises: offset=$offset, limit=$limit, page=${currentPage + 1}');
        }

        final response = await http.get(
          Uri.parse('$exerciseBaseUrl/exercises?offset=$offset&limit=$limit'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));

        if (kDebugMode) {
          debugPrint('Exercises API Response Status: ${response.statusCode}');
        }

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonData = json.decode(response.body);
          
          if (jsonData['success'] == true && jsonData['data'] != null) {
            dynamic exercisesData = jsonData['data']['exercises'];
            
            if (exercisesData == null || (exercisesData is List && exercisesData.isEmpty)) {
              hasMore = false;
              break;
            }
            
            List<dynamic> exercises = exercisesData is List ? exercisesData : [exercisesData];
            
            final exerciseList = exercises.map((json) {
              try {
                return ExerciseModel.fromJson(json);
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('Error parsing exercise: $e');
                }
                return null;
              }
            }).where((exercise) => exercise != null).cast<ExerciseModel>().toList();
            
            allExercises.addAll(exerciseList);
            
            final nextPage = jsonData['data']['nextPage'];
            hasMore = nextPage != null && exercises.length == limit;
            offset += limit;
            currentPage++;
            
            if (kDebugMode) {
              debugPrint('Loaded ${exerciseList.length} exercises, total: ${allExercises.length}');
            }
          } else {
            throw Exception('API returned success: false');
          }
        } else {
          throw Exception('Failed to load exercises: ${response.statusCode}');
        }
      }
      
      _allExercisesCache = allExercises;
      _cacheTime = DateTime.now();
      
      if (kDebugMode) {
        debugPrint('Total exercises loaded: ${allExercises.length}');
      }
      
      return allExercises;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching exercises: $e');
      }
      throw Exception('Error fetching exercises: $e');
    }
  }

  /// **Get Available Muscles**
  static Future<List<String>> getAvailableMuscles() async {
    if (_availableMusclesCache != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheTimeout) {
      return _availableMusclesCache!;
    }

    try {
      if (kDebugMode) {
        debugPrint('Analyzing available muscles from exercise data...');
      }
      
      final allExercises = await getAllExercises();
      final muscleExerciseCount = <String, int>{};
      
      for (final entry in muscleMapping.entries) {
        final muscleGroup = entry.key;
        final mappedNames = entry.value;
        
        int count = 0;
        for (final exercise in allExercises) {
          bool matches = false;
          
          for (final targetMuscle in exercise.targetMuscles) {
            final targetLower = targetMuscle.toLowerCase().trim();
            if (mappedNames.any((mapped) {
              final mappedLower = mapped.toLowerCase().trim();
              return targetLower == mappedLower || 
                     targetLower.contains(mappedLower) ||
                     mappedLower.contains(targetLower);
            })) {
              matches = true;
              break;
            }
          }
          
          if (!matches) {
            for (final bodyPart in exercise.bodyParts) {
              final partLower = bodyPart.toLowerCase().trim();
              if (mappedNames.any((mapped) {
                final mappedLower = mapped.toLowerCase().trim();
                return partLower == mappedLower || 
                       partLower.contains(mappedLower) ||
                       mappedLower.contains(partLower);
              })) {
                matches = true;
                break;
              }
            }
          }
          
          if (matches) {
            count++;
          }
        }
        
        if (count > 0) {
          muscleExerciseCount[muscleGroup] = count;
        }
      }
      
      final sortedMuscles = muscleExerciseCount.entries
          .where((entry) => entry.value > 0)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final availableMuscles = sortedMuscles.map((e) => e.key).toList();
      _availableMusclesCache = availableMuscles;
      
      if (kDebugMode) {
        debugPrint('Available muscles with exercise counts:');
        for (final entry in sortedMuscles.take(10)) {
          debugPrint('  ${entry.key}: ${entry.value} exercises');
        }
      }
      
      return availableMuscles;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error analyzing available muscles: $e');
      }
      
      return [
        'biceps', 'triceps', 'chest', 'back', 
        'abs', 'glutes', 'quadriceps', 'hamstrings', 
        'shoulders', 'forearms'
      ];
    }
  }

  /// **Filter Exercises by Muscle**
  static Future<List<ExerciseModel>> getExercisesByMuscle(String muscle) async {
    try {
      if (kDebugMode) {
        debugPrint('Fetching exercises for muscle: $muscle');
      }
      
      final allExercises = await getAllExercises();
      final mappedMuscles = muscleMapping[muscle.toLowerCase()] ?? [muscle.toLowerCase()];
      
      final filteredExercises = allExercises.where((exercise) {
        bool matchesTarget = exercise.targetMuscles.any((targetMuscle) {
          final targetLower = targetMuscle.toLowerCase().trim();
          
          return mappedMuscles.any((mapped) {
            final mappedLower = mapped.toLowerCase().trim();
            return targetLower == mappedLower || 
                   targetLower.contains(mappedLower) ||
                   mappedLower.contains(targetLower) ||
                   _isMuscleMatch(targetLower, mappedLower);
          });
        });
        
        bool matchesBodyPart = exercise.bodyParts.any((bodyPart) {
          final partLower = bodyPart.toLowerCase().trim();
          
          return mappedMuscles.any((mapped) {
            final mappedLower = mapped.toLowerCase().trim();
            return partLower == mappedLower || 
                   partLower.contains(mappedLower) ||
                   mappedLower.contains(partLower) ||
                   _isBodyPartMatch(partLower, mappedLower, muscle);
          });
        });
        
        return matchesTarget || matchesBodyPart;
      }).toList();
      
      if (kDebugMode) {
        debugPrint('Found ${filteredExercises.length} exercises for muscle: $muscle');
      }
      
      return filteredExercises;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error filtering exercises by muscle: $e');
      }
      throw Exception('Error filtering exercises by muscle: $e');
    }
  }

  /// **Search Exercises**
  static Future<List<ExerciseModel>> searchExercises(String query) async {
    try {
      final allExercises = await getAllExercises();
      
      return allExercises.where((exercise) =>
        exercise.name.toLowerCase().contains(query.toLowerCase()) ||
        exercise.targetMuscles.any((muscle) => 
          muscle.toLowerCase().contains(query.toLowerCase())) ||
        exercise.equipments.any((equipment) => 
          equipment.toLowerCase().contains(query.toLowerCase())) ||
        exercise.bodyParts.any((part) => 
          part.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    } catch (e) {
      throw Exception('Error searching exercises: $e');
    }
  }

  /// **Get Muscle Statistics**
  static Future<Map<String, int>> getMuscleStatistics() async {
    if (_muscleStatsCache != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheTimeout) {
      return _muscleStatsCache!;
    }

    try {
      final availableMuscles = await getAvailableMuscles();
      final stats = <String, int>{};
      
      for (final muscle in availableMuscles) {
        try {
          final exercises = await getExercisesByMuscle(muscle);
          stats[muscle] = exercises.length;
        } catch (e) {
          stats[muscle] = 0;
        }
      }
      
      stats.removeWhere((key, value) => value == 0);
      
      final sortedStats = Map.fromEntries(
        stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
      );
      
      _muscleStatsCache = sortedStats;
      return sortedStats;
    } catch (e) {
      return {};
    }
  }

  /// **Get Exercise Statistics**
  static Future<Map<String, dynamic>> getExerciseStats() async {
    try {
      final allExercises = await getAllExercises();
      final muscleStats = await getMuscleStatistics();
      final availableMuscles = await getAvailableMuscles();
      
      return {
        'totalExercises': allExercises.length,
        'totalMuscles': availableMuscles.length,
        'muscleStats': muscleStats,
        'availableMuscles': availableMuscles,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error getting exercise stats: $e');
    }
  }

  /// **Clear Cache**
  static void clearCache() {
    _allExercisesCache = null;
    _availableMusclesCache = null;
    _muscleStatsCache = null;
    _cacheTime = null;
    if (kDebugMode) {
      debugPrint('✅ Cache cleared');
    }
  }

  // Helper methods
  static bool _isMuscleMatch(String target, String mapped) {
    if ((target.contains('upper') && mapped.contains('back')) ||
        (target.contains('back') && mapped.contains('upper'))) {
      return true;
    }
    
    if ((target.contains('biceps') && mapped.contains('biceps')) ||
        (target.contains('triceps') && mapped.contains('triceps'))) {
      return true;
    }
        
    return false;
  }

  static bool _isBodyPartMatch(String bodyPart, String mapped, String originalMuscle) {
    final bodyPartMuscleMapping = {
      'upper arms': ['biceps', 'triceps'],
      'upper legs': ['quadriceps', 'hamstrings', 'glutes'],
      'lower legs': ['calves'],
      'waist': ['abs'],
      'back': ['back', 'traps'],
    };
    
    final musclesForBodyPart = bodyPartMuscleMapping[bodyPart] ?? [];
    return musclesForBodyPart.contains(originalMuscle.toLowerCase());
  }

  /// **Get All Muscles From API - untuk muscle_stats_dialog.dart**
  static Future<List<String>> getAllMusclesFromApi() async {
    try {
      final allExercises = await getAllExercises();
      final allMusclesSet = <String>{};
      
      // Kumpulkan semua target muscles dari API
      for (final exercise in allExercises) {
        for (final muscle in exercise.targetMuscles) {
          allMusclesSet.add(muscle.toLowerCase().trim());
        }
        
        // Tambahkan juga dari body parts
        for (final bodyPart in exercise.bodyParts) {
          allMusclesSet.add(bodyPart.toLowerCase().trim());
        }
      }
      
      // Convert set ke list dan sort
      final allMusclesList = allMusclesSet.toList()..sort();
      
      if (kDebugMode) {
        debugPrint('Found ${allMusclesList.length} unique muscles from API');
      }
      
      return allMusclesList;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting all muscles from API: $e');
      }
      // Fallback list
      return [
        'biceps', 'triceps', 'chest', 'back', 'shoulders', 'abs',
        'quadriceps', 'hamstrings', 'glutes', 'calves', 'forearms', 'traps'
      ];
    }
  }

  /// **Analyze Muscle Data - untuk api_test_screen.dart**
  static Future<Map<String, dynamic>> analyzeMuscleData() async {
    try {
      final allExercises = await getAllExercises();
      final allMuscles = await getAllMusclesFromApi();
      final availableMuscles = await getAvailableMuscles();
      final muscleStats = await getMuscleStatistics();
      
      // Analisis detail
      final muscleAnalysis = <String, Map<String, dynamic>>{};
      
      for (final muscle in allMuscles) {
        final exercisesForMuscle = allExercises.where((exercise) =>
          exercise.targetMuscles.any((target) => 
            target.toLowerCase().contains(muscle.toLowerCase())) ||
          exercise.bodyParts.any((part) => 
            part.toLowerCase().contains(muscle.toLowerCase()))
        ).toList();
        
        muscleAnalysis[muscle] = {
          'exerciseCount': exercisesForMuscle.length,
          'isAvailable': availableMuscles.contains(muscle),
          'exercises': exercisesForMuscle.take(5).map((e) => e.name).toList(),
        };
      }
      
      return {
        'totalExercises': allExercises.length,
        'totalApiMuscles': allMuscles.length,
        'availableMuscles': availableMuscles.length,
        'muscleStats': muscleStats,
        'muscleAnalysis': muscleAnalysis,
        'lastAnalyzed': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error analyzing muscle data: $e');
      }
      return {
        'error': e.toString(),
        'totalExercises': 0,
        'totalApiMuscles': 0,
        'availableMuscles': 0,
      };
    }
  }

  /// **Get Currency Rates - Mock implementation untuk equipment_service.dart**
  static Future<Map<String, dynamic>> getCurrencyRates(String baseCurrency) async {
    // Mock currency rates karena API sudah dihapus
    const mockRates = {
      'USD': {
        'IDR': 15000.0,
        'EUR': 0.85,
        'GBP': 0.75,
        'JPY': 110.0,
        'SGD': 1.35,
        'MYR': 4.2,
      },
      'IDR': {
        'USD': 0.000067,
        'EUR': 0.000057,
        'GBP': 0.00005,
        'JPY': 0.0073,
        'SGD': 0.00009,
        'MYR': 0.00028,
      },
    };
    
    final rates = mockRates[baseCurrency.toUpperCase()];
    
    if (rates != null) {
      return {
        'success': true,
        'base': baseCurrency,
        'conversion_rates': rates,
        'time_last_update_utc': DateTime.now().toUtc().toIso8601String(),
      };
    } else {
      throw Exception('Currency $baseCurrency not supported');
    }
  }

  // Legacy methods for backward compatibility
  static Future<List<ExerciseModel>> getExercisesByMuscleSimple(String muscle) => getExercisesByMuscle(muscle);
  static Future<List<ExerciseModel>> getExercisesByTargetMuscle(String muscle) => getExercisesByMuscle(muscle);
  static List<String> getAvailableTargetMuscles() => ['biceps', 'triceps', 'chest', 'back', 'abs', 'glutes', 'quadriceps', 'hamstrings', 'shoulders', 'forearms'];
}