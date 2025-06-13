import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implement actual API login
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Simulate successful login
      _user = User(
        id: '1',
        name: 'John Doe',
        email: email,
        role: 'employee',
      );

      // Save auth token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'dummy_token');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear stored token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        // TODO: Validate token with API
        // For now, simulate a valid token
        _user = User(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          role: 'employee',
        );
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
