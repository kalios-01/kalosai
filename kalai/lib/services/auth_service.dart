import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:kalai/models/food_item.dart';

class AuthService {
  final String baseUrl = 'https://6370-115-99-180-230.ngrok-free.app';
  final storage = const FlutterSecureStorage();
  final int tokenValiditySeconds = 1800; // 1/2 hour, adjust if your API returns a different expiry

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _storeTokens(data);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await _storeTokens(data);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  Future<void> _storeTokens(Map<String, dynamic> data) async {
    print('Storing tokens...');
    print('Access token: ${data['access_token']}');
    print('Refresh token: ${data['refresh_token']}');
    await storage.write(key: 'access_token', value: data['access_token']);
    await storage.read(key: 'access_token').then((value) => print('Stored access token: $value'));
    await storage.write(key: 'refresh_token', value: data['refresh_token']);
    await storage.write(key: 'token_type', value: data['token_type']);
    await storage.write(key: 'token_timestamp', value: DateTime.now().toIso8601String());
    print('Tokens stored successfully');
  }

  Future<void> logout() async {
    print('Logging out...');
    await storage.deleteAll();
    print('Logged out successfully');
  }

  Future<bool> deleteAccountApi() async {
    print('Calling delete account API...');
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      print('No access token found for deletion');
      // Ensure local tokens and flags are cleared if we can't even attempt API deletion
      await storage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_complete');
      await prefs.remove('needs_profile_setup_after_signup');
      print('Local tokens and flags cleared (no token found).');
      return false;
    }

    final url = Uri.parse('$baseUrl/api/v1/auth/delete_account');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Delete account API response status: ${response.statusCode}');
      print('Delete account API response body: ${response.body}');

      // Consider 200 OK and 204 No Content as success for deletion
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Account deleted on server, clearing local tokens and flags...');
        // Clear secure storage tokens
        await storage.deleteAll();

        // Clear relevant SharedPreferences flags
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_complete');
        await prefs.remove('needs_profile_setup_after_signup');

        print('Local tokens and flags cleared.');
        return true;
      } else {
        // Handle other non-success status codes
        print('Account deletion API failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception during delete account API call: $e');
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    print('Getting access token...');
    final accessToken = await storage.read(key: 'access_token');
    print('Retrieved access token: $accessToken');
    final timestampStr = await storage.read(key: 'token_timestamp');
    print('Token timestamp: $timestampStr');
    
    if (accessToken == null || timestampStr == null) {
      print('No token or timestamp found');
    }
    
    final timestamp = DateTime.tryParse(timestampStr ?? '');
    if (timestamp == null && timestampStr != null) {
      print('Invalid timestamp format');
      // Consider clearing invalid timestamp or token here if it causes issues
    }
    
    final now = DateTime.now();
    final difference = timestamp != null ? now.difference(timestamp).inSeconds : -1;
    print('Token age: ${difference != -1 ? '$difference seconds' : 'N/A'}');
    
    if (timestamp != null && difference > tokenValiditySeconds) {
      print('Token expired, attempting refresh...');
      final refreshed = await _refreshToken();
      if (refreshed) {
        final newToken = await storage.read(key: 'access_token');
        print('Token refreshed successfully: ${newToken != null}');
        return newToken;
      } else {
        print('Token refresh failed');
        return null;
      }
    }
    
    print('Using existing token or no token available');
    return accessToken;
  }

  Future<bool> _refreshToken() async {
    print('Refreshing token...');
    final refreshToken = await storage.read(key: 'refresh_token');
    print('Refresh token exists: ${refreshToken != null}');
    
    if (refreshToken == null) {
      print('No refresh token found, cannot refresh');
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      print('Refresh response status: ${response.statusCode}');
      print('Refresh response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeTokens(data);
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    print('Refresh failed');
    return false;
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refresh_token');
  }

  Future<String?> getTokenType() async {
    return await storage.read(key: 'token_type');
  }

  Future<DateTime?> getTokenTimestamp() async {
    final timestampStr = await storage.read(key: 'token_timestamp');
    if (timestampStr == null) return null;
    return DateTime.tryParse(timestampStr);
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    print('Fetching profile data...');
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      print('No access token found for fetching profile.');
      return null;
    }

    final url = Uri.parse('$baseUrl/api/v1/profile/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Fetch profile API response status: ${response.statusCode}');
      print('Fetch profile API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Profile data fetched successfully.');
        return data;
      } else if (response.statusCode == 404) {
        print('Profile not found for user.');
        return null; // Profile doesn't exist
      } else {
        print('Failed to fetch profile with status: ${response.statusCode}');
        return null; // Other error
      }
    } catch (e) {
      print('Exception during fetch profile API call: $e');
      return null; // Network or other exception
    }
  }

  Future<bool> updateProfileFieldApi({required String fieldName, required dynamic fieldValue}) async {
    print('Calling update profile field API...');
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      print('No access token found for updating profile field.');
      return false;
    }

    // Format the value based on field type
    dynamic formattedValue;
    if (fieldName == 'age') {
      // Ensure age is in YYYY-MM-DD format
      try {
        final date = DateTime.parse(fieldValue.toString());
        formattedValue = DateFormat('yyyy-MM-dd').format(date);
      } catch (e) {
        print('Error formatting date: $e');
        return false;
      }
    } else if (fieldName == 'height' || fieldName == 'current_weight' || fieldName == 'goal_weight') {
      // Ensure these are integers
      try {
        formattedValue = (fieldValue as num).toInt();
      } catch (e) {
        print('Error formatting number: $e');
        return false;
      }
    } else {
      // For other fields (like gender), just use as is
      formattedValue = fieldValue;
    }

    print('Formatted value for API: $formattedValue');

    // First, fetch current profile data
    final currentProfile = await fetchProfile();
    if (currentProfile == null) {
      print('Failed to fetch current profile data');
      return false;
    }

    // Update the specific field in the profile data
    final updatedProfile = Map<String, dynamic>.from(currentProfile);
    updatedProfile[fieldName] = formattedValue;

    print('Sending updated profile data: $updatedProfile');

    final url = Uri.parse('$baseUrl/api/v1/profile/update');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updatedProfile),
      );

      print('Update profile field API response status: ${response.statusCode}');
      print('Update profile field API response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Profile field updated successfully on server.');
        return true;
      } else {
        print('Update profile field API failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception during update profile field API call: $e');
      return false;
    }
  }

  Future<http.Response> get(String endpoint) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('No access token available');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    print('AuthService GET request to URL: $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('No access token available');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    print('AuthService DELETE request to URL: $url');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    return response;
  }
} 