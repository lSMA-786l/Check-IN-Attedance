import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication Service - Manages login state
class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // In-memory fallback for web
  bool _isLoggedInMemory = false;

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      debugPrint('SharedPreferences error, using in-memory storage: $e');
      return _isLoggedInMemory;
    }
  }

  /// Set user as logged in
  Future<void> login() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
    } catch (e) {
      debugPrint('SharedPreferences error, using in-memory storage: $e');
      _isLoggedInMemory = true;
    }
  }

  /// Set user as logged out and clear all data
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('SharedPreferences error, using in-memory storage: $e');
      _isLoggedInMemory = false;
    }
  }
}
