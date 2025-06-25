import 'dart:convert';
import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  final String baseUrl = 'http://65.0.181.77:8000';
  final storage = const FlutterSecureStorage();
  
  // Initialize Google Sign-In with your client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '192557787396-7ikrsb8k6g8ili20qqj4ks9h3qrop12g.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
    ],
  );

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      print('🚀 Starting Google Sign-In process...');
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return {'success': false, 'message': 'Sign in cancelled by user'};
      }

      print('✅ Google Sign-In successful for user: ${googleUser.email}');
      print('👤 User details:');
      print('  Name: ${googleUser.displayName}');
      print('  Email: ${googleUser.email}');
      print('  ID: ${googleUser.id}');
      print('  Photo URL: ${googleUser.photoUrl}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('🔑 Google Auth details:');
      print('  ID Token exists: ${googleAuth.idToken != null}');
      print('  Access Token exists: ${googleAuth.accessToken != null}');
      print('  ID Token preview: ${googleAuth.idToken != null ? googleAuth.idToken!.substring(0, min(50, googleAuth.idToken!.length)) + '...' : 'null'}');

      print('📤 Sending to server:');
      final fullUrl = '$baseUrl/v1/auth/google';
      print('  Base URL: $baseUrl');
      print('  Full URL: $fullUrl');
      print('  ID Token: ${googleAuth.idToken}');

      // Send to your backend for verification and user data retrieval
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': googleAuth.idToken,
        }),
      );

      print('📥 Server response:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('Decoded backend response: ${data}');
        
        // Store Google ID token for future API calls
        await storage.write(key: 'access_token', value: googleAuth.idToken);
        print('✅ Stored Google ID token for future use');
        // Store user info
        await _storeUserInfo(data);
        print('✅ Google Sign-In completed successfully');
        return {'success': true, 'data': data};
      } else {
        // Handle server errors gracefully
        String errorMessage = 'Server error: ${response.statusCode}. Please try again later.';
        try {
          // Attempt to parse a JSON error response, if available
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['detail'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          // If the body is not JSON, use the raw text
          errorMessage = 'Server error (${response.statusCode}): ${response.body}';
        }
        print('❌ Google Sign-In failed: $errorMessage');
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      return {'success': false, 'message': 'Google sign-in failed: $e'};
    }
  }

  Future<void> _storeUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userInfo['name'] ?? '');
    await prefs.setString('user_email', userInfo['email'] ?? '');
    await prefs.setString('user_username', userInfo['username'] ?? '');
    await prefs.setString('user_photo', userInfo['profile_photo'] ?? '');
    await prefs.setString('user_id', userInfo['id'] ?? '');
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await storage.deleteAll();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.remove('user_username');
      await prefs.remove('user_photo');
      await prefs.remove('user_id');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<String?> getAccessToken() async {
    print('🔍 Getting access token (which is the Google ID token)...');
    return await storage.read(key: 'access_token');
  }

  Future<bool> signInSilentlyAndRefresh() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) {
        // User is not signed in or needs to sign in again.
        await storage.delete(key: 'access_token');
        return false;
      }
      final auth = await account.authentication;
      if (auth.idToken == null) {
        // For some reason, we couldn't get an ID token.
        return false;
      }
      // Store the fresh ID token.
      await storage.write(key: 'access_token', value: auth.idToken);
      print('✅ ID Token refreshed silently.');
      return true;
    } catch (e) {
      print('❌ Error during silent sign-in/ID token refresh: $e');
      return false;
    }
  }

  Future<bool> isSignedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
} 