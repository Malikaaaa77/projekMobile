import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MuscleStatsDialog extends StatefulWidget {
  const MuscleStatsDialog({super.key});

  @override
  MuscleStatsDialogState createState() => MuscleStatsDialogState();
}

class MuscleStatsDialogState extends State<MuscleStatsDialog> {
  Map<String, int>? _muscleStats;
  List<String>? _availableMuscles;
  List<String>? _allApiMuscles;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMuscleAnalysis();
  }

  Future<void> _loadMuscleAnalysis() async {
    try {
      final muscleStats = await ApiService.getMuscleStatistics();
      final availableMuscles = await ApiService.getAvailableMuscles();
      final allApiMuscles = await ApiService.getAllMusclesFromApi();
      
      if (mounted) {
        setState(() {
          _muscleStats = muscleStats;
          _availableMuscles = availableMuscles;
          _allApiMuscles = allApiMuscles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.insights, color: Colors.blue[700]),
          const SizedBox(width: 8),
          const Text('Muscle Analysis'),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: double.maxFinite,
              height: 400,
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: Colors.blue[700],
                      tabs: const [
                        Tab(text: 'Available'),
                        Tab(text: 'Statistics'),
                        Tab(text: 'All Muscles'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildAvailableMusclesTab(),
                          _buildStatisticsTab(),
                          _buildAllMusclesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildAvailableMusclesTab() {
    if (_availableMuscles == null) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Muscles with Exercises: ${_availableMuscles!.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _availableMuscles!.length,
            itemBuilder: (context, index) {
              final muscle = _availableMuscles![index];
              final count = _muscleStats?[muscle] ?? 0;
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        muscle.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count exercises',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    if (_muscleStats == null) {
      return const Center(child: Text('No statistics available'));
    }

    final sortedStats = _muscleStats!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Exercises:'),
                  Text(
                    '${sortedStats.fold(0, (sum, entry) => sum + entry.value)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Muscle Groups:'),
                  Text(
                    '${sortedStats.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Exercises per Muscle (sorted by count):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: sortedStats.length,
            itemBuilder: (context, index) {
              final entry = sortedStats[index];
              final maxCount = sortedStats.first.value;
              final percentage = (entry.value / maxCount * 100).round(); // Fixed: Now used
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '$percentage%', // Fixed: Using the percentage variable
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.value}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / maxCount,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllMusclesTab() {
    if (_allApiMuscles == null) {
      return const Center(child: Text('No API muscle data available'));
    }

    final availableSet = _availableMuscles?.toSet() ?? <String>{};
    final musclesWithExercises = <String>[];
    final musclesWithoutExercises = <String>[];

    for (final muscle in _allApiMuscles!) {
      if (availableSet.contains(muscle.toLowerCase())) {
        musclesWithExercises.add(muscle);
      } else {
        musclesWithoutExercises.add(muscle);
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total in API:'),
                    Text(
                      '${_allApiMuscles!.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('With Exercises:'),
                    Text(
                      '${musclesWithExercises.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Without Exercises:'),
                    Text(
                      '${musclesWithoutExercises.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Muscles with exercises
          Text(
            'Muscles with Exercises (${musclesWithExercises.length}):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          ...musclesWithExercises.map((muscle) => Container(
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                const SizedBox(width: 8),
                Text(muscle.toUpperCase()),
              ],
            ),
          )),
          
          const SizedBox(height: 16),
          
          // Muscles without exercises
          Text(
            'Muscles without Exercises (${musclesWithoutExercises.length}):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          ...musclesWithoutExercises.map((muscle) => Container(
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.cancel, color: Colors.red[600], size: 16),
                const SizedBox(width: 8),
                Text(muscle.toUpperCase()),
              ],
            ),
          )),
        ],
      ),
    );
  }
}