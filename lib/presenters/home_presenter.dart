import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../utils/session_manager.dart';
import 'package:flutter/foundation.dart';

abstract class HomeViewContract {
  void showUserData(UserModel user);
  void showStats(Map<String, int> stats);
  void showError(String message);
  void showLoading();
  void hideLoading();
}

class HomePresenter {
  final HomeViewContract view;

  HomePresenter(this.view);

  Future<void> loadUserData() async {
    view.showLoading();
    
    try {
      final user = await SessionManager.getCurrentUser();
      if (user != null) {
        view.showUserData(user);
        await _loadStats(user.id!);
      } else {
        view.showError('User not found');
      }
    } catch (e) {
      view.showError('Failed to load user data: $e');
    } finally {
      view.hideLoading();
    }
  }
  Future<void> _loadStats(int userId) async {
    try {
      // Get target muscles from API
      final targetMuscles = ApiService.getAvailableTargetMuscles();
      
      // Load actual favorites and history counts from database
      final favorites = await DatabaseService.instance.getFavoritesByUserId(userId);
      final history = await DatabaseService.instance.getHistoryByUserId(userId);
      
      final stats = {
        'favorites': favorites.length,
        'completed': history.length,
        'total_muscles': targetMuscles.length,
        'active_muscles': 0,
      };
      
      // Add individual muscle stats (all 0 for now)
      for (String muscle in targetMuscles) {
        stats[muscle] = 0;
      }
      
      view.showStats(stats);
      
      if (kDebugMode) {
        debugPrint('Stats loaded - Favorites: ${favorites.length}, Completed: ${history.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading stats: $e');
      }
      // Provide minimal fallback stats
      final fallbackStats = {
        'favorites': 0,
        'completed': 0,
        'total_muscles': 10,
        'active_muscles': 0,
      };
      view.showStats(fallbackStats);
    }
  }
  Future<void> refreshData() async {
    await loadUserData();
  }

  void navigateToExercises() {
    if (kDebugMode) {
      debugPrint('Navigating to exercises');
    }
  }

  void navigateToFavorites() {
    if (kDebugMode) {
      debugPrint('Navigating to favorites');
    }
  }

  void navigateToProfile() {
    if (kDebugMode) {
      debugPrint('Navigating to profile');
    }
  }
}