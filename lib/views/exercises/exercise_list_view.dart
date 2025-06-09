import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../../models/exercise_model.dart';
import '../../presenters/exercise_presenter.dart';
import '../../widgets/equipment_price_widget.dart';
import '../../utils/session_manager.dart';
import '../../services/notification_service.dart';
import '../../services/database_service.dart';
import '../../models/history_model.dart';
import '../../models/favorite_model.dart';


class ExerciseListView extends StatefulWidget {
  final String? muscle;
  final Function(bool)? onVisibilityChanged; // Add callback for visibility changes

  const ExerciseListView({
    super.key, // Fix: Use super.key
    this.muscle,
    this.onVisibilityChanged, // Optional callback
  });
  
  @override
  State<ExerciseListView> createState() => ExerciseListViewState();
}

class ExerciseListViewState extends State<ExerciseListView>
    with WidgetsBindingObserver
    implements ExerciseViewContract {
  late ExercisePresenter _presenter;
  
  List<ExerciseModel> _exercises = [];
  List<String> _availableMuscles = [];
  String? _selectedMuscle;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Favorites
  Set<String> _favoriteExerciseIds = {};
    // UI state
  final ScrollController _scrollController = ScrollController();
  
  // Shake detection
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;  
  static const double _shakeThreshold = 12.0;
  static const int _shakeCooldown = 2000; // milliseconds
  bool _isPageActive = true; // Track if page is active
  
  @override
  void initState() {
    super.initState();
    _presenter = ExercisePresenter(this);
    _selectedMuscle = widget.muscle;
    
    // Add observer for app lifecycle
    WidgetsBinding.instance.addObserver(this);
    
    _initializeData();
    _loadFavorites();
    _initializeShakeDetection();
    
    // Search listener
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  // Method to handle page visibility changes from parent navigation
  void setPageVisibility(bool isVisible) {
    if (_isPageActive != isVisible) {
      _isPageActive = isVisible;
      
      if (kDebugMode) {
        debugPrint('ExerciseListView: Page visibility changed to $isVisible');
      }
      
      // Update shake detection based on visibility
      if (isVisible) {
        _startShakeDetection();
      } else {
        _stopShakeDetection();
      }
      
      // Notify parent if callback provided
      widget.onVisibilityChanged?.call(isVisible);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _accelerometerSubscription?.cancel(); // Cancel shake detection
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _presenter.loadAvailableMuscles();
    
    if (_selectedMuscle != null) {
      await _presenter.loadExercisesByMuscle(_selectedMuscle!);
    } else {
      await _presenter.loadAllExercises();
    }
  }
  Future<void> _loadFavorites() async {
    try {
      final user = await SessionManager.getCurrentUser();
      if (user != null) {
        final favorites = await DatabaseService.instance.getFavoritesByUserId(user.id!);
        setState(() {
          _favoriteExerciseIds = favorites.map((fav) => fav.exerciseName).toSet();
        });
        
        if (kDebugMode) {
          debugPrint('Loaded ${favorites.length} favorites for user ${user.id}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading favorites: $e');
      }
    }
  }

  // Filter exercises based on search query
  List<ExerciseModel> get _filteredExercises {
    if (_searchQuery.isEmpty) {
      return _exercises;
    }
    
    return _exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(_searchQuery) ||
             exercise.targetMuscles.any((muscle) => 
                muscle.toLowerCase().contains(_searchQuery)) ||
             exercise.bodyParts.any((part) => 
                part.toLowerCase().contains(_searchQuery)) ||
             exercise.equipments.any((equipment) => 
                equipment.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: _buildScrollToTopFab(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _selectedMuscle != null 
            ? '${_selectedMuscle!.toUpperCase()} Exercises'
            : 'All Exercises',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _handleRefresh,
          tooltip: 'Refresh exercises',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises, muscles, equipment...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Muscle Filter Chips
          if (_availableMuscles.isNotEmpty) ...[
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableMuscles.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildMuscleChip('All', _selectedMuscle == null);
                  }
                  
                  final muscle = _availableMuscles[index - 1];
                  final isSelected = _selectedMuscle?.toLowerCase() == muscle.toLowerCase();
                  return _buildMuscleChip(muscle, isSelected);
                },
              ),
            ),
          ],
          
          // Results Count
          if (_exercises.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Showing ${_filteredExercises.length} of ${_exercises.length} exercises',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMuscleChip(String muscle, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          muscle == 'All' ? muscle : muscle.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue[700], // Dark blue for unselected, white for selected
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (muscle == 'All') {
            _handleMuscleSelection(null);
          } else {
            _handleMuscleSelection(muscle);
          }
        },
        backgroundColor: Colors.white, // Solid white background for unselected
        selectedColor: Colors.blue[700], // Dark blue background for selected
        side: BorderSide(
          color: isSelected ? Colors.blue[700]! : Colors.blue[300]!,
          width: 1.5,
        ),
        checkmarkColor: Colors.white,
        elevation: 3, // Increased elevation for better visibility
        shadowColor: Colors.black38,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    
    if (_exercises.isEmpty) {
      return _buildEmptyState();
    }
    
    if (_filteredExercises.isEmpty) {
      return _buildNoSearchResultsState();
    }
    
    return _buildExerciseList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading exercises...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Failed to load exercises',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedMuscle != null
                  ? 'No exercises available for $_selectedMuscle'
                  : 'No exercises available at the moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No search results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No exercises found for "$_searchQuery"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _filteredExercises.length,
        itemBuilder: (context, index) {
          final exercise = _filteredExercises[index];
          return _buildExerciseCard(exercise, index);
        },
      ),
    );
  }
  
  Widget _buildExerciseCard(ExerciseModel exercise, int index) {
    final isFavorite = _favoriteExerciseIds.contains(exercise.name);
    
    // Replace print with debugPrint for better logging
    if (kDebugMode) {
      debugPrint('==== DEBUG [ExerciseCard]: Exercise "${exercise.name}" target muscles: ${exercise.targetMuscles}');
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header with Icon (No Image/GIF)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[600]!,
                  Colors.blue[500]!,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Favorite Button Overlay
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _toggleFavorite(exercise),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Exercise Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target Muscles
                if (exercise.targetMuscles.isNotEmpty) ...[
                  const Text(
                    'Target Muscles:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: exercise.targetMuscles.map((muscle) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          muscle.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // **EQUIPMENT PRICE COMPARISON WIDGET - ALWAYS RENDERED**
                EquipmentPriceWidget(
                  muscle: exercise.targetMuscles.isNotEmpty
                      ? exercise.targetMuscles.first.toLowerCase()
                      : 'biceps', // fallback to ensure widget always has data
                ),
                
                // Secondary Muscles
                if (exercise.secondaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Secondary Muscles:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: exercise.secondaryMuscles.map((muscle) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          muscle.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                // Instructions
                if (exercise.instructions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: exercise.instructions.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[600],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
                
                // Action Buttons
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsCompleted(exercise),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Mark Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleFavorite(exercise),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? Colors.red : null,
                        ),
                        label: Text(isFavorite ? 'Favorited' : 'Add Favorite'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          foregroundColor: isFavorite ? Colors.red : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildScrollToTopFab() {
    return FloatingActionButton(
      mini: true,
      onPressed: () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      child: const Icon(Icons.keyboard_arrow_up),
    );
  }

  // Event Handlers
  void _handleMuscleSelection(String? muscle) {
    setState(() {
      _selectedMuscle = muscle;
      _searchController.clear();
    });
    
    if (muscle != null) {
      _presenter.loadExercisesByMuscle(muscle);
    } else {
      _presenter.loadAllExercises();
    }
  }

  Future<void> _handleRefresh() async {
    await _initializeData();
    await _loadFavorites();
  }
  // Simplified database operations for now
  Future<void> _toggleFavorite(ExerciseModel exercise) async {
    try {
      final user = await SessionManager.getCurrentUser();
      if (user == null) {
        _showMessage('Please login to manage favorites');
        return;
      }

      final isFavorite = _favoriteExerciseIds.contains(exercise.name);
      
      if (isFavorite) {
        // Remove from favorites
        await DatabaseService.instance.removeFavorite(user.id!, exercise.name);
        setState(() {
          _favoriteExerciseIds.remove(exercise.name);
        });
        _showMessage('Removed from favorites');
      } else {
        // Add to favorites
        final favoriteModel = FavoriteModel(
          userId: user.id!,
          exerciseName: exercise.name,
          exerciseType: exercise.targetMuscles.join(', '),
          muscle: exercise.targetMuscles.isNotEmpty ? exercise.targetMuscles.first : 'Unknown',
          equipment: exercise.equipments.isNotEmpty ? exercise.equipments.first : 'None',
          difficulty: 'Intermediate', // Default difficulty
          instructions: exercise.instructions.join(' '),
          addedAt: DateTime.now(),
        );
        
        await DatabaseService.instance.addFavorite(favoriteModel);
        setState(() {
          _favoriteExerciseIds.add(exercise.name);
        });
        
        // Show favorite notification
        await NotificationService.instance.showFavoriteAdded(exercise.name);
        _showMessage('Added to favorites ❤️');
      }
      
      // Reload favorites
      await _loadFavorites();
    } catch (e) {
      _showMessage('Error updating favorites');
      if (kDebugMode) {
        debugPrint('Error toggling favorite: $e');
      }
    }
  }
  Future<void> _markAsCompleted(ExerciseModel exercise) async {
    try {
      final user = await SessionManager.getCurrentUser();
      if (user == null) {
        _showMessage('Please login to mark exercises as completed');
        return;
      }

      // Create history record
      final historyModel = HistoryModel(
        userId: user.id!,
        exerciseName: exercise.name,
        exerciseType: exercise.targetMuscles.join(', '),
        muscle: exercise.targetMuscles.isNotEmpty ? exercise.targetMuscles.first : 'Unknown',
        equipment: exercise.equipments.isNotEmpty ? exercise.equipments.first : 'None',
        difficulty: 'Intermediate', // Default difficulty
        instructions: exercise.instructions.join(' '),
        completedAt: DateTime.now(),
      );

      // Save to database
      await DatabaseService.instance.addHistory(historyModel);

      // Show completion notification
      await NotificationService.instance.showExerciseCompleted(exercise.name);

      // Get total exercise count for milestone notifications
      final allHistory = await DatabaseService.instance.getHistoryByUserId(user.id!);
      await NotificationService.instance.showMilestoneNotification(allHistory.length);

      _showMessage('Exercise marked as completed! 🎉');

      if (kDebugMode) {
        debugPrint('Exercise completed: ${exercise.name}');
      }
    } catch (e) {
      _showMessage('Error marking exercise as completed');
      if (kDebugMode) {
        debugPrint('Error marking completed: $e');
      }
    }
  }
  
  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // App lifecycle observer methods
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App comes to foreground - start shake detection if this page is active
        if (_isPageActive) {
          _startShakeDetection();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // App goes to background - stop shake detection
        _stopShakeDetection();
        break;
      case AppLifecycleState.hidden:
        _stopShakeDetection();
        break;
    }
  }

  // Shake detection methods
  void _startShakeDetection() {
    // Only start if not already active and page is active
    if (_accelerometerSubscription == null && _isPageActive) {
      _initializeShakeDetection();
      if (kDebugMode) {
        debugPrint('Shake detection started for exercises page');
      }
    }
  }

  void _stopShakeDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    if (kDebugMode) {
      debugPrint('Shake detection stopped');
    }
  }

  void _initializeShakeDetection() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          // Only detect shake if page is still active
          if (_isPageActive) {
            _detectShake(event);
          }
        },
        onError: (error) {
          if (kDebugMode) {
            debugPrint('Accelerometer error: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize shake detection: $e');
      }
    }
  }

  void _detectShake(AccelerometerEvent event) {
    final now = DateTime.now();
    
    // Check cooldown period
    if (_lastShakeTime != null && 
        now.difference(_lastShakeTime!).inMilliseconds < _shakeCooldown) {
      return;
    }

    // Calculate acceleration magnitude
    final acceleration = sqrt(
      event.x * event.x + 
      event.y * event.y + 
      event.z * event.z
    );

    // Detect shake if acceleration exceeds threshold
    if (acceleration > _shakeThreshold) {
      _lastShakeTime = now;
      _onShakeDetected();
    }
  }

  void _onShakeDetected() async {
    if (kDebugMode) {
      debugPrint('Shake detected! Refreshing exercises...');
    }
    
    // Show feedback to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.vibration, color: Colors.white),
              SizedBox(width: 8),
              Text('Shake detected! Refreshing exercises...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    // Trigger refresh
    await _handleRefresh();
  }
  
  @override
  void showExercises(List<ExerciseModel> exercises) {
    if (mounted) {
      setState(() {
        _exercises = exercises;
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  @override
  void showAvailableMuscles(List<String> muscles) {
    if (mounted) {
      setState(() {
        _availableMuscles = muscles;
      });
    }
  }

  @override
  void showError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  @override
  void showLoading() {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
  }

  @override
  void hideLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}