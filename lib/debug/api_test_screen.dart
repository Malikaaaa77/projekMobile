import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  ApiTestScreenState createState() => ApiTestScreenState();
}

class ApiTestScreenState extends State<ApiTestScreen> {
  String _testResult = '';
  bool _isLoading = false;

  Future<void> _testApiConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing API connection and muscle mapping...';
    });

    try {
      // Test 1: Analyze muscle data
      _updateResult('\n=== MUSCLE DATA ANALYSIS ===');
      final analysisData = await ApiService.analyzeMuscleData();
      
      _updateResult('Step 1: API Data Analysis');
      _updateResult('Total exercises: ${analysisData['totalExercises']}');
      _updateResult('Unique target muscles: ${(analysisData['targetMuscles'] as List).length}');
      _updateResult('Unique body parts: ${(analysisData['bodyParts'] as List).length}');
      
      // Show sample data
      final targetMuscles = analysisData['targetMuscles'] as List;
      final bodyParts = analysisData['bodyParts'] as List;
      _updateResult('\nSample target muscles: ${targetMuscles.take(10).join(', ')}');
      _updateResult('Sample body parts: ${bodyParts.take(10).join(', ')}');
      
      // Test 2: Test problematic muscles
      _updateResult('\n=== TESTING PROBLEMATIC MUSCLES ===');
      final problematicMuscles = ['spine', 'traps', 'calves'];
      
      for (final muscle in problematicMuscles) {
        _updateResult('\nTesting: $muscle');
        try {
          final exercises = await ApiService.getExercisesByMuscle(muscle);
          _updateResult('✅ $muscle: Found ${exercises.length} exercises');
          if (exercises.isNotEmpty) {
            _updateResult('   Sample: ${exercises.take(2).map((e) => e.name).join(', ')}');
          }
        } catch (e) {
          _updateResult('❌ $muscle: Error - $e');
        }
      }
      
      // Test 3: Test muscle statistics
      _updateResult('\n=== MUSCLE STATISTICS ===');
      final muscleStats = await ApiService.getMuscleStatistics();
      _updateResult('Muscle groups with exercises: ${muscleStats.length}');
      
      final sortedStats = muscleStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      _updateResult('\nTop 10 muscle groups:');
      for (int i = 0; i < 10 && i < sortedStats.length; i++) {
        final entry = sortedStats[i];
        _updateResult('${i + 1}. ${entry.key}: ${entry.value} exercises');
      }
      
      // Test 4: Available muscles
      _updateResult('\n=== AVAILABLE MUSCLES ===');
      final availableMuscles = await ApiService.getAvailableMuscles();
      _updateResult('Available muscle groups: ${availableMuscles.length}');
      _updateResult('List: ${availableMuscles.join(', ')}');
      
      // Test 5: Check specific muscle mapping
      _updateResult('\n=== MUSCLE MAPPING TEST ===');
      final mapping = {
        'spine': ['lower back', 'upper back', 'back'],
        'traps': ['traps', 'trapezius', 'upper back'],
        'calves': ['calves', 'gastrocnemius', 'soleus'],
      };
      
      for (final entry in mapping.entries) {
        final muscle = entry.key;
        final mappedNames = entry.value;
        _updateResult('\n$muscle maps to: ${mappedNames.join(', ')}');
        
        // Check if any mapped names exist in API data
        int foundCount = 0;
        for (final mapped in mappedNames) {
          if (targetMuscles.any((apiMuscle) => 
              apiMuscle.toString().toLowerCase().contains(mapped.toLowerCase()))) {
            foundCount++;
            _updateResult('   ✅ Found "$mapped" in target muscles');
          } else if (bodyParts.any((apiPart) => 
              apiPart.toString().toLowerCase().contains(mapped.toLowerCase()))) {
            foundCount++;
            _updateResult('   ✅ Found "$mapped" in body parts');
          } else {
            _updateResult('   ❌ "$mapped" not found');
          }
        }
        _updateResult('   Total found: $foundCount/${mappedNames.length}');
      }
      
      setState(() {
        _testResult += '\n\n=== TEST COMPLETED ===';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult += '\n\nERROR: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testSpecificMuscle() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Specific Muscle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Enter muscle name',
            hintText: 'e.g., spine, traps, calves',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Test'),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _testResult = 'Testing muscle: $result';
      });
      
      try {
        final exercises = await ApiService.getExercisesByMuscle(result);
        setState(() {
          _testResult += '\n\nResults for "$result":';
          _testResult += '\nFound ${exercises.length} exercises';
          
          if (exercises.isNotEmpty) {
            _testResult += '\n\nExercises:';
            for (int i = 0; i < exercises.length && i < 10; i++) {
              final exercise = exercises[i];
              _testResult += '\n${i + 1}. ${exercise.name}';
              _testResult += '\n   Targets: ${exercise.targetMuscles.join(', ')}';
              _testResult += '\n   Body parts: ${exercise.bodyParts.join(', ')}';
            }
            
            if (exercises.length > 10) {
              _testResult += '\n... and ${exercises.length - 10} more';
            }
          } else {
            _testResult += '\n\nNo exercises found for "$result"';
            _testResult += '\nTry checking the muscle mapping or use a different name.';
          }
          
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _testResult += '\n\nError testing "$result": $e';
          _isLoading = false;
        });
      }
    }
  }

  void _updateResult(String message) {
    setState(() {
      _testResult += '\n$message';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle API Test'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _testResult = '';
              });
            },
            tooltip: 'Clear Results',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testApiConnection,
                    icon: _isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.analytics),
                    label: Text(_isLoading ? 'Testing...' : 'Full Analysis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testSpecificMuscle,
                    icon: const Icon(Icons.search),
                    label: const Text('Test Muscle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: const Text(
                'This test will analyze muscle data, test problematic muscles (spine, traps, calves), and show mapping results.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult.isEmpty ? 'Click "Full Analysis" to start comprehensive testing\nor "Test Muscle" to test a specific muscle group.' : _testResult,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}