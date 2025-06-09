import '../models/favorite_model.dart';
import '../models/history_model.dart';
import '../services/database_service.dart';
import '../utils/session_manager.dart';
import 'package:flutter/foundation.dart';

abstract class FavoritesViewContract {
  void showFavorites(List<FavoriteModel> favorites);
  void showHistory(List<HistoryModel> history);
  void showError(String message);
  void showSuccess(String message);
  void showLoading();
  void hideLoading();
}

class FavoritesPresenter {
  final FavoritesViewContract view;

  FavoritesPresenter(this.view);

  Future<void> loadUserData() async {
    view.showLoading();
    
    try {
      final user = await SessionManager.getCurrentUser();
      if (user != null) {
        final favorites = await DatabaseService.instance.getFavoritesByUser(user.id!);
        final history = await DatabaseService.instance.getHistoryByUser(user.id!);
        
        view.showFavorites(favorites);
        view.showHistory(history);
      } else {
        view.showError('User not found');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading user data: $e');
      }
      view.showError('Failed to load data: $e');
    } finally {
      view.hideLoading();
    }
  }

  // Add missing loadData method
  Future<void> loadData() async {
    await loadUserData();
  }

  // Add missing removeFavorite method
  Future<void> removeFavorite(String exerciseName) async {
    view.showLoading();
    
    try {
      final user = await SessionManager.getCurrentUser();
      if (user == null) {
        view.showError('User not found');
        view.hideLoading();
        return;
      }

      await DatabaseService.instance.removeFavorite(user.id!, exerciseName);
      view.showSuccess('Removed from favorites');
      
      // Reload data to refresh the list
      await loadUserData();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error removing favorite: $e');
      }
      view.hideLoading();
      view.showError('Failed to remove favorite: $e');
    }
  }

  Future<void> refreshData() async {
    await loadUserData();
  }
}