
import '../views/login/login_view.dart';
import '../services/database_service.dart';
import '../utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import '../utils/password_utils.dart';

class LoginPresenter {
  final LoginViewContract view;

  LoginPresenter(this.view);

  Future<void> login(String email, String password) async {
    view.showLoading();

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        view.showError('Please fill in all fields');
        view.hideLoading();
        return;
      }

      // Check user by email
      final user = await DatabaseService.instance.getUserByEmail(email.trim());

      if (user == null) {
        view.showError('User not found');
        view.hideLoading();
        return;
      }

      // Verify password
      if (!PasswordUtils.verifyPassword(password, user.password)) {
        view.showError('Invalid password');
        view.hideLoading();
        return;
      }

      // Save session
      await SessionManager.saveSession(user);

      if (kDebugMode) {
        debugPrint('Login successful for user: ${user.email}');
      }

      view.hideLoading();
      view.navigateToHome();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login error: $e');
      }
      view.hideLoading();
      view.showError('Login failed: ${e.toString()}');
    }
  }
}