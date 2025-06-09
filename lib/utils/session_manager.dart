import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class SessionManager {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userFullNameKey = 'user_full_name'; // Fixed
  static const String _isLoggedInKey = 'is_logged_in';

  static Future<void> saveSession(UserModel user) async { // Fixed method name
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, user.id!);
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setString(_userFullNameKey, user.fullName); // Fixed
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    if (!isLoggedIn) return null;
    
    final userId = prefs.getInt(_userIdKey);
    if (userId == null) return null;
    
    try {
      // Get full user data from database
      return await DatabaseService.instance.getUserById(userId);
    } catch (e) {
      // Fallback: create user from session data
      final email = prefs.getString(_userEmailKey) ?? '';
      final fullName = prefs.getString(_userFullNameKey) ?? ''; // Fixed
      
      if (email.isNotEmpty) {
        return UserModel(
          id: userId,
          username: email.split('@')[0], // Fixed: added required parameter
          email: email,
          password: '', // Empty for security
          fullName: fullName, // Fixed: added required parameter
          createdAt: DateTime.now(), // Fixed: added required parameter
          updatedAt: DateTime.now(), // Fixed: added required parameter
        );
      }
      return null;
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userFullNameKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
}