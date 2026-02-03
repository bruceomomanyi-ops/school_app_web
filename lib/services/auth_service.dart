import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';
  static const String _userIdKey = 'auth_user_id';
  static const String _userDataKey = 'auth_user_data';

  static String? _token;
  static String? _role;
  static int? _userId;
  static Map<String, dynamic>? _userData;
  static bool _isInitialized = false;

  // Getters
  static String? get token => _token;
  static String? get role => _role;
  static int? get userId => _userId;
  static Map<String, dynamic>? get userData => _userData;
  static bool get isAuthenticated => _token != null;

  // Initialize auth state from shared_preferences
  static Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _role = prefs.getString(_roleKey);
    _userId = prefs.getInt(_userIdKey);

    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        _userData = jsonDecode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        _userData = null;
      }
    }

    _isInitialized = true;
  }

  // Check if user is authenticated (async version)
  static Future<bool> isLoggedIn() async {
    await init();
    return _token != null;
  }

  // Save auth data after login
  static Future<void> saveAuthData({
    required String token,
    required String role,
    required int userId,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userDataKey, jsonEncode(userData));

    _token = token;
    _role = role;
    _userId = userId;
    _userData = userData;
  }

  // Clear auth data on logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userDataKey);

    _token = null;
    _role = null;
    _userId = null;
    _userData = null;
  }

  // Get headers with auth token
  static Map<String, String> getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Check if user has specific role
  static bool hasRole(String requiredRole) {
    return _role == requiredRole;
  }

  // Check if user is admin
  static bool isAdmin() {
    return _role == 'admin';
  }

  // Check if user is teacher
  static bool isTeacher() {
    return _role == 'teacher';
  }

  // Check if user is student
  static bool isStudent() {
    return _role == 'student';
  }
}
