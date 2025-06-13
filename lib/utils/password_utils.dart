// lib/utils/password_utils.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordUtils {
  static const String _salt = 'fitness_app_salt_2024';
  
  static String hashPassword(String password) {
    var bytes = utf8.encode(password + _salt);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  static bool verifyPassword(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }
}