import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthService get authService => _authService;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.signup(
      name: name,
      email: email,
      password: password,
    );

    _isLoading = false;
    
    if (result['success']) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    print('Login attempt for email: $email');
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    _isLoading = false;
    
    if (result['success']) {
      print('Login successful');
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } else {
      print('Login failed: ${result['message']}');
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    print('Logging out...');
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
    print('Logged out successfully');
  }

  Future<void> checkAuthStatus() async {
    print('Checking auth status...');
    final token = await _authService.getAccessToken();
    print('Auth token check result: ${token != null}');
    _isAuthenticated = token != null;
    notifyListeners();
    print('Auth status updated: $_isAuthenticated');
  }

  Future<bool> deleteAccount() async {
    print('Attempting to delete account...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _authService.deleteAccountApi();

    _isLoading = false;
    if (success) {
      print('Account deleted successfully');
      _isAuthenticated = false;
      notifyListeners();
      return true;
    } else {
      print('Account deletion failed');
      _error = 'Failed to delete account.'; // Generic error message
      notifyListeners();
      return false;
    }
  }
} 