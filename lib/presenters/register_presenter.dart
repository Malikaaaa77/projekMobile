
import '../views/login/register_view.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';
import '../utils/password_utils.dart';

class RegisterPresenter {
  final RegisterViewContract view;

  RegisterPresenter(this.view);

  Future<void> register(String fullName, String email, String password) async {
    view.showLoading();

    try {
      // Validate input
      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        view.showError('Please fill in all fields');
        view.hideLoading();
        return;
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        view.showError('Please enter a valid email');
        view.hideLoading();
        return;
      }

      if (password.length < 6) {
        view.showError('Password must be at least 6 characters');
        view.hideLoading();
        return;
      }

      // Check if email already exists
      final existingUser = await DatabaseService.instance.getUserByEmail(email.trim());
      if (existingUser != null) {
        view.showError('Email already exists');
        view.hideLoading();
        return;
      }

      // Hash password
      String hashedPassword = PasswordUtils.hashPassword(password);

      // Create username from email (part before @)
      final username = email.split('@')[0].toLowerCase();

      // Check if username exists, if so, add numbers
      String finalUsername = username;
      int counter = 1;
      while (await DatabaseService.instance.getUserByUsername(finalUsername) != null) {
        finalUsername = '$username$counter';
        counter++;
      }

      final now = DateTime.now();
      final user = UserModel(
        username: finalUsername,
        email: email.trim(),
        fullName: fullName.trim(),
        password: hashedPassword,
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseService.instance.createUser(user);

      if (kDebugMode) {
        debugPrint('Registration successful for user: ${user.email}');
      }

      view.hideLoading();
      view.showSuccess('Account created successfully!');
      
      // Navigate back to login after short delay
      await Future.delayed(const Duration(seconds: 1));
      view.navigateToLogin();

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Registration error: $e');
      }
      view.hideLoading();
      view.showError('Registration failed: ${e.toString()}');
    }
  }
}