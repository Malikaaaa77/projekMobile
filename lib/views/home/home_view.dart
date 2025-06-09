import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../presenters/home_presenter.dart';
import '../exercises/exercise_list_view.dart';
import '../favorites/favorites_history_view.dart';
import '../profile/profile_view.dart';
import '../location/gym_finder_view.dart';
import 'quick_time_widget.dart'; // ADD THIS IMPORT (same folder)

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> implements HomeViewContract {
  late HomePresenter _presenter;
  UserModel? _user;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter(this);
    _presenter.loadUserData();
    
    // MVP Pattern: Log view initialization
    print('[MVP] HomeView initialized at UTC: ${DateTime.now().toUtc()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _presenter.refreshData();
              print('[MVP] HomeView: User refreshed data');
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  if (_user != null) ...[
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[700]!, Colors.blue[500]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back!',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        _user!.fullName, // Shows: Malikaaaa77
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // **QUICK TIME WIDGET - MVP INTEGRATION**
                    const QuickTimeWidget(),
                    
                    const SizedBox(height: 24),
                    
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Favorites',
                            '${_stats['favorites'] ?? 0}',
                            Icons.favorite,
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Completed',
                            '${_stats['completed'] ?? 0}',
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                      GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildActionCard(
                          'Exercises',
                          Icons.fitness_center,
                          Colors.blue,
                          () => _navigateToExercises(),
                        ),
                         _buildActionCard(
                          'Gym Finder',
                          Icons.location_on,
                          Colors.green,
                          () => _navigateToGymFinder(),
                        ),
                        _buildActionCard(
                          'Favorites',
                          Icons.favorite,
                          Colors.red,
                          () => _navigateToFavorites(),
                        ),
                        _buildActionCard(
                          'Profile',
                          Icons.person,
                          Colors.purple,
                          () => _navigateToProfile(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  // ... KEEP ALL YOUR EXISTING METHODS UNCHANGED ...
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods - KEEP ALL EXISTING
  void _navigateToExercises() {
    _presenter.navigateToExercises();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExerciseListView()),
    );
  }
  void _navigateToFavorites() {
    _presenter.navigateToFavorites();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesHistoryView()),
    );
  }

  void _navigateToProfile() {
    _presenter.navigateToProfile();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileView()),
    );
  }

  void _navigateToGymFinder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GymFinderView()),
    );
  }

  // Interface methods - KEEP ALL EXISTING
  @override
  void showUserData(UserModel user) {
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  void showStats(Map<String, int> stats) {
    if (mounted) {
      setState(() {
        _stats = stats;
      });
    }
  }

  @override
  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void showLoading() {
    if (mounted) {
      setState(() {
        _isLoading = true;
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