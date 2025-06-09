import '../models/user_model.dart';
import '../services/database_service.dart';
import '../utils/session_manager.dart';

abstract class ProfileViewContract {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showSuccess(String message);
  void showUserData(UserModel user);
}

class ProfilePresenter {
  final ProfileViewContract view;

  ProfilePresenter(this.view);

  Future<void> loadUserData() async {
    view.showLoading();
    
    try {
      final user = await SessionManager.getCurrentUser();
      if (user != null) {
        view.showUserData(user);
      } else {
        view.showError('User not found');
      }
    } catch (e) {
      view.showError('Failed to load user data: $e');
    } finally {
      view.hideLoading();
    }
  }

  Future<void> updateProfile(String fullName, String email) async { // Fixed parameter names
    view.showLoading();
    
    try {
      final currentUser = await SessionManager.getCurrentUser();
      if (currentUser == null) {
        view.showError('User not found');
        view.hideLoading();
        return;
      }

      final updatedUser = currentUser.copyWith(
        fullName: fullName, // Fixed: use fullName instead of name
        email: email,
        updatedAt: DateTime.now(), // Fixed: added required parameter
      );

      await DatabaseService.instance.updateUser(updatedUser);
      await SessionManager.saveSession(updatedUser);
      
      view.hideLoading();
      view.showSuccess('Profile updated successfully');
      view.showUserData(updatedUser);
    } catch (e) {
      view.hideLoading();
      view.showError('Failed to update profile: $e');
    }
  }

  Future<void> submitSuggestion(String suggestion) async {
    view.showLoading();
    
    try {
      final user = await SessionManager.getCurrentUser();
      if (user == null) {
        view.showError('User not found');
        view.hideLoading();
        return;
      }

      await DatabaseService.instance.addSuggestion(user.id!, suggestion); // Fixed method name
      
      view.hideLoading();
      view.showSuccess('Suggestion submitted successfully');
    } catch (e) {
      view.hideLoading();
      view.showError('Failed to submit suggestion: $e');
    }
  }
}