import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';

class ApiService {
  // Updated ExerciseDB API 
  static const String exerciseBaseUrl = 'https://exercisedb-api.vercel.app/api/v1';
  
  // Currency API dengan API Key
  static const String currencyBaseUrl = 'https://v6.exchangerate-api.com/v6';
  static const String currencyApiKey = 'a408c0961add60bd972fd3a4';
  
  // TimeAPI.io
  static const String timeBaseUrl = 'https://timeapi.io/api/time/current/zone';

  // Cache untuk menyimpan data
  static List<ExerciseModel>? _allExercisesCache;
  static List<String>? _availableMusclesCache;
  static Map<String, int>? _muscleStatsCache;
  static DateTime? _cacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 30);

  // Improved muscle mapping berdasarkan API real data
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

  // Get all exercises dengan limit yang aman
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
      int maxPages = 8; // Increase to get more data
      int currentPage = 0;
      
      // Ambil data secara bertahap (pagination)
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
        );

        if (kDebugMode) {
          debugPrint('Exercises API Response Status: ${response.statusCode}');
        }

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonData = json.decode(response.body);
          
          if (jsonData['success'] == true && jsonData['data'] != null) {
            List<dynamic> exercises = jsonData['data']['exercises'];
            
            if (exercises.isEmpty) {
              hasMore = false;
              break;
            }
            
            final exerciseList = exercises.map((json) => ExerciseModel.fromJson(json)).toList();
            allExercises.addAll(exerciseList);
            
            // Check if there's next page
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
          throw Exception('Failed to load exercises: ${response.statusCode} - ${response.body}');
        }
      }
      
      // Update cache
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

  // Get available muscles yang benar-benar ada exercise-nya
  static Future<List<String>> getAvailableMuscles() async {
    // Check cache first
    if (_availableMusclesCache != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheTimeout) {
      return _availableMusclesCache!;
    }

    try {
      if (kDebugMode) {
        debugPrint('Analyzing available muscles from exercise data...');
      }
      
      // Ambil semua exercise data
      final allExercises = await getAllExercises();
      
      // Count exercises per muscle group menggunakan mapping
      final muscleExerciseCount = <String, int>{};
      
      for (final entry in muscleMapping.entries) {
        final muscleGroup = entry.key;
        final mappedNames = entry.value;
        
        int count = 0;
        for (final exercise in allExercises) {
          bool matches = false;
          
          // Check target muscles
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
          
          // Check body parts juga
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
        
        // Only include muscle groups that have exercises
        if (count > 0) {
          muscleExerciseCount[muscleGroup] = count;
        }
      }
      
      // Check for additional muscles dari API yang tidak ada di mapping
      final extraMuscles = <String>{};
      for (final exercise in allExercises) {
        for (final targetMuscle in exercise.targetMuscles) {
          final targetLower = targetMuscle.toLowerCase().trim();
          
          // Check if this muscle is not covered by our mapping
          bool isCovered = false;
          for (final entry in muscleMapping.entries) {
            if (entry.value.any((mapped) {
              final mappedLower = mapped.toLowerCase().trim();
              return targetLower == mappedLower || 
                     targetLower.contains(mappedLower) ||
                     mappedLower.contains(targetLower);
            })) {
              isCovered = true;
              break;
            }
          }
          
          if (!isCovered && targetLower.isNotEmpty) {
            extraMuscles.add(targetLower);
          }
        }
      }
      
      // Add extra muscles that have enough exercises
      for (final extraMuscle in extraMuscles) {
        final count = allExercises.where((exercise) =>
          exercise.targetMuscles.any((target) =>
            target.toLowerCase().trim() == extraMuscle
          )
        ).length;
        
        if (count >= 3) { // At least 3 exercises
          muscleExerciseCount[extraMuscle] = count;
        }
      }
      
      // Sort by exercise count (descending) dan ambil muscle yang ada exercise-nya
      final sortedMuscles = muscleExerciseCount.entries
          .where((entry) => entry.value > 0)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final availableMuscles = sortedMuscles.map((e) => e.key).toList();
      
      // Update cache
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
      
      // Fallback ke list manual yang sudah teruji
      return [
        'biceps', 'triceps', 'chest', 'back', 
        'abs', 'glutes', 'quadriceps', 'hamstrings', 
        'shoulders', 'forearms'
      ];
    }
  }

  // Improved exercise filtering dengan better mapping
  static Future<List<ExerciseModel>> getExercisesByMuscle(String muscle) async {
    try {
      if (kDebugMode) {
        debugPrint('Fetching exercises for muscle: $muscle');
      }
      
      final allExercises = await getAllExercises();
      
      // Get mapped muscle names
      final mappedMuscles = muscleMapping[muscle.toLowerCase()] ?? [muscle.toLowerCase()];
      
      if (kDebugMode) {
        debugPrint('Mapped muscles for $muscle: $mappedMuscles');
      }
      
      // Filter exercises dengan improved matching
      final filteredExercises = allExercises.where((exercise) {
        // Check target muscles dengan exact dan partial matching
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
        
        // Check body parts dengan special cases
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
        
        // Check secondary muscles juga
        bool matchesSecondary = exercise.secondaryMuscles.any((secondaryMuscle) {
          final secondaryLower = secondaryMuscle.toLowerCase().trim();
          
          return mappedMuscles.any((mapped) {
            final mappedLower = mapped.toLowerCase().trim();
            return secondaryLower == mappedLower || 
                   secondaryLower.contains(mappedLower) ||
                   mappedLower.contains(secondaryLower);
          });
        });
        
        return matchesTarget || matchesBodyPart || (matchesSecondary && muscle.toLowerCase() != 'chest');
      }).toList();
      
      if (kDebugMode) {
        debugPrint('Found ${filteredExercises.length} exercises for muscle: $muscle');
        if (filteredExercises.isNotEmpty) {
          debugPrint('Sample exercises: ${filteredExercises.take(3).map((e) => e.name).join(', ')}');
        }
      }
      
      return filteredExercises;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error filtering exercises by muscle: $e');
      }
      throw Exception('Error filtering exercises by muscle: $e');
    }
  }

  // Helper method untuk muscle matching
  static bool _isMuscleMatch(String target, String mapped) {
    // Special cases for muscle matching
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

  // Helper method untuk body part matching
  static bool _isBodyPartMatch(String bodyPart, String mapped, String originalMuscle) {
    // Map body parts to muscle groups
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

  // Get muscle statistics dengan improved counting
  static Future<Map<String, int>> getMuscleStatistics() async {
    // Check cache first
    if (_muscleStatsCache != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheTimeout) {
      return _muscleStatsCache!;
    }

    try {
      final availableMuscles = await getAvailableMuscles();
      final stats = <String, int>{};
      
      // Count exercises for each available muscle
      for (final muscle in availableMuscles) {
        try {
          final exercises = await getExercisesByMuscle(muscle);
          stats[muscle] = exercises.length;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error counting exercises for $muscle: $e');
          }
          stats[muscle] = 0;
        }
      }
      
      // Remove muscles with 0 exercises
      stats.removeWhere((key, value) => value == 0);
      
      // Sort by count (descending)
      final sortedStats = Map.fromEntries(
        stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
      );
      
      // Update cache
      _muscleStatsCache = sortedStats;
      
      if (kDebugMode) {
        debugPrint('Muscle statistics (top 10):');
        sortedStats.entries.take(10).forEach((entry) {
          debugPrint('  ${entry.key}: ${entry.value} exercises');
        });
      }
      
      return sortedStats;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting muscle statistics: $e');
      }
      return {};
    }
  }

  // **ADD: Missing getAllMusclesFromApi method**
  static Future<List<String>> getAllMusclesFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('$exerciseBaseUrl/muscles'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          List<dynamic> musclesData = jsonData['data'];
          List<String> muscles = musclesData
              .map((muscle) => muscle['name'].toString())
              .toList();
          
          return muscles;
        }
      }
      
      throw Exception('Failed to load muscles from API');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching muscles from API: $e');
      }
      // Fallback to available muscles
      return await getAvailableMuscles();
    }
  }

  // Legacy methods for backward compatibility
  static Future<List<ExerciseModel>> getExercisesByMuscleSimple(String muscle) => getExercisesByMuscle(muscle);
  static Future<List<ExerciseModel>> getExercisesByTargetMuscle(String muscle) => getExercisesByMuscle(muscle);
  static List<String> getAvailableTargetMuscles() => ['biceps', 'triceps', 'chest', 'back', 'abs', 'glutes', 'quadriceps', 'hamstrings', 'shoulders', 'forearms'];

  // **FIX: Wrap single statements in braces**
  static Future<Map<String, dynamic>> analyzeMuscleData() async {
    try {
      final allExercises = await getAllExercises();
      
      // Extract semua unique target muscles dan body parts
      final allTargetMuscles = <String>{};
      final allBodyParts = <String>{};
      final allEquipments = <String>{};
      
      for (final exercise in allExercises) {
        for (final muscle in exercise.targetMuscles) {
          allTargetMuscles.add(muscle.toLowerCase().trim());
        }
        for (final part in exercise.bodyParts) {
          allBodyParts.add(part.toLowerCase().trim());
        }
        for (final equipment in exercise.equipments) {
          allEquipments.add(equipment.toLowerCase().trim());
        }
      }
      
      if (kDebugMode) {
        debugPrint('All unique target muscles: ${allTargetMuscles.toList()..sort()}');
        debugPrint('All unique body parts: ${allBodyParts.toList()..sort()}');
        debugPrint('All unique equipments: ${allEquipments.toList()..sort()}');
      }
      
      return {
        'targetMuscles': allTargetMuscles.toList()..sort(),
        'bodyParts': allBodyParts.toList()..sort(),
        'equipments': allEquipments.toList()..sort(),
        'totalExercises': allExercises.length,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error analyzing muscle data: $e');
      }
      return {};
    }
  }

  // Clear cache method
  static void clearCache() {
    _allExercisesCache = null;
    _availableMusclesCache = null;
    _muscleStatsCache = null;
    _cacheTime = null;
    if (kDebugMode) {
      debugPrint('✅ Cache cleared');
    }
  }

  // Currency dan timezone methods
  static Future<Map<String, dynamic>> getCurrencyRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$currencyBaseUrl/$currencyApiKey/latest/$baseCurrency'),
        headers: {
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load currency rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching currency rates: $e');
    }
  }

  static Future<Map<String, dynamic>> getTimezone(String timezone) async {
    try {
      final encodedTimezone = Uri.encodeComponent(timezone);
      final response = await http.get(
        Uri.parse('$timeBaseUrl?timeZone=$encodedTimezone'),
        headers: {
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load timezone: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching timezone: $e');
    }
  }

  static Map<String, dynamic> getTimezoneManual(String timezone) {
    final now = DateTime.now().toUtc();
    final timezoneOffsets = {
      'Asia/Jakarta': 7,
      'Asia/Makassar': 8,
      'Asia/Jayapura': 9,
      'Europe/London': 0,
      'Europe/Amsterdam': 1,
      'America/New_York': -5,
      'Asia/Tokyo': 9,
      'Asia/Singapore': 8,
      'Australia/Sydney': 11,
    };

    final offset = timezoneOffsets[timezone] ?? 0;
    final localTime = now.add(Duration(hours: offset));

    return {
      'year': localTime.year,
      'month': localTime.month,
      'day': localTime.day,
      'hour': localTime.hour,
      'minute': localTime.minute,
      'seconds': localTime.second,
      'dateTime': localTime.toIso8601String(),
      'timeZone': timezone,
      'dayOfWeek': _getDayOfWeek(localTime.weekday),
    };
  }

  static String _getDayOfWeek(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  // Additional search and filter methods
  static Future<List<ExerciseModel>> getExercisesByBodyPart(String bodyPart) async {
    try {
      final allExercises = await getAllExercises();
      
      final filteredExercises = allExercises.where((exercise) {
        return exercise.bodyParts.any((part) {
          final partLower = part.toLowerCase().trim();
          final bodyPartLower = bodyPart.toLowerCase().trim();
          
          return partLower == bodyPartLower || 
                 partLower.contains(bodyPartLower) ||
                 bodyPartLower.contains(partLower);
        });
      }).toList();
      
      return filteredExercises;
    } catch (e) {
      throw Exception('Error filtering exercises by body part: $e');
    }
  }

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

  static Future<Map<String, dynamic>> getExerciseStats() async {
    try {
      final allExercises = await getAllExercises();
      final muscleStats = await getMuscleStatistics();
      final availableMuscles = await getAvailableMuscles();
      final analysisData = await analyzeMuscleData();
      
      return {
        'totalExercises': allExercises.length,
        'totalMuscles': availableMuscles.length,
        'muscleStats': muscleStats,
        'availableMuscles': availableMuscles,
        'analysisData': analysisData,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Error getting exercise stats: $e');
    }
  }
}