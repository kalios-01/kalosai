import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userInfo;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '192557787396-7ikrsb8k6g8ili20qqj4ks9h3qrop12g.apps.googleusercontent.com',
    // ...
  );

  GoogleAuthService get authService => _googleAuthService;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userInfo => _userInfo;

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _googleAuthService.signInWithGoogle();

    _isLoading = false;
    
    if (result['success']) {
      _isAuthenticated = true;
      _userInfo = result['data'];
      notifyListeners();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    print('Signing out...');
    await _googleAuthService.signOut();
    _isAuthenticated = false;
    _userInfo = null;
    notifyListeners();
    print('Signed out successfully');
  }

  Future<void> checkAuthStatus() async {
    print('Checking auth status...');
    final signedIn = await _googleAuthService.signInSilentlyAndRefresh();
    _isAuthenticated = signedIn;
    
    if (signedIn) {
      // Load user info from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _userInfo = {
        'name': prefs.getString('user_name'),
        'email': prefs.getString('user_email'),
        'photoUrl': prefs.getString('user_photo'),
        'id': prefs.getString('user_id'),
      };
    }
    
    notifyListeners();
    print('Auth status updated: $_isAuthenticated');
  }

  Future<bool> deleteAccount() async {
    print('Attempting to delete account...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    // You might want to implement account deletion API call here
    // For now, we'll just sign out
    await signOut();

    _isLoading = false;
    notifyListeners();
    return true;
  }
} 