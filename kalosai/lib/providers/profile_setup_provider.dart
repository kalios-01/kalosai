import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileSetupProvider extends ChangeNotifier {
  final GoogleAuthService _authService = GoogleAuthService();
  String? gender;
  String? activityLevel;
  String unit = 'metric'; // 'metric' or 'imperial'
  double? height; // cm or inches
  double? weight; // kg or lbs
  DateTime? birthDate;

  // Added fields to store fetched profile data
  Map<String, dynamic>? _userProfileData;
  bool _isFetchingProfile = false;
  bool _isUpdatingProfile = false;

  Map<String, dynamic>? get userProfileData => _userProfileData;
  bool get isFetchingProfile => _isFetchingProfile;
  bool get isUpdatingProfile => _isUpdatingProfile;

  void setGender(String value) {
    gender = value;
    notifyListeners();
  }
  void setActivityLevel(String value) {
    activityLevel = value;
    notifyListeners();
  }
  void setUnit(String value) {
    unit = value;
    notifyListeners();
  }

  void setHeight(double value) {
    height = value;
    notifyListeners();
  }

  void setWeight(double value) {
    weight = value;
    notifyListeners();
  }

  void setBirthDate(DateTime value) {
    birthDate = value;
    notifyListeners();
  }

  // Method to fetch user profile data
  Future<void> fetchUserProfile() async {
    print('Fetching user profile data in provider...');
    _isFetchingProfile = true;
    notifyListeners();

    // For now, we'll implement a simple profile fetch
    // You may need to implement this method in GoogleAuthService
    final accessToken = await _authService.getAccessToken();
    if (accessToken != null) {
      try {
        final response = await http.get(
          Uri.parse('${_authService.baseUrl}/api/v1/profile/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );
        
        if (response.statusCode == 200) {
          _userProfileData = jsonDecode(response.body);
        }
      } catch (e) {
        print('Error fetching profile: $e');
      }
    }

    _isFetchingProfile = false;
    print('Finished fetching user profile: $_userProfileData');
    notifyListeners();
  }

  // Method to update a specific profile field
  Future<bool> updateProfileField({required String fieldName, required dynamic fieldValue}) async {
     print('Updating profile field: $fieldName with value: $fieldValue');
    _isUpdatingProfile = true;
    notifyListeners();

    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      _isUpdatingProfile = false;
      notifyListeners();
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('${_authService.baseUrl}/api/v1/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({fieldName: fieldValue}),
      );

      _isUpdatingProfile = false;
      if (response.statusCode == 200) {
        print('Profile field updated successfully.');
        await fetchUserProfile();
        return true;
      } else {
        print('Profile field update failed.');
        return false;
      }
    } catch (e) {
      _isUpdatingProfile = false;
      print('Error updating profile field: $e');
      return false;
    }
  }

  Future<bool> submitProfile(BuildContext context) async {
    // Convert height and weight to metric before saving
    double? heightCm = height;
    double? weightKg = weight;
    if (unit == 'imperial') {
      if (height != null) heightCm = height! * 2.54;
      if (weight != null) weightKg = weight! * 0.453592;
    }
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (gender != null) await prefs.setString('profile_gender', gender!);
    if (activityLevel != null) await prefs.setString('profile_activity_level', activityLevel!);
    if (heightCm != null) await prefs.setDouble('profile_height_cm', heightCm);
    if (weightKg != null) await prefs.setDouble('profile_weight_kg', weightKg);
    if (birthDate != null) await prefs.setString('profile_birthdate', birthDate!.toIso8601String());

    // Only send to backend if logged in
    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      // Not logged in, just save locally and return true
      return true;
    }
    final url = Uri.parse('${_authService.baseUrl}/api/v1/profile/');

    // First check if profile exists
    try {
      final checkResponse = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final body = {
        "gender": gender?.toLowerCase() ?? "male",
        "age": birthDate?.toIso8601String().split('T').first ?? DateTime.now().toIso8601String().split('T').first,
        "height": height ?? 175.0,
        "weight": weight ?? 70.0,
        "activity_level": activityLevel ?? '0 - 2',
      };


      // If profile exists (200), update it. If not (404), create new
      final response = await (checkResponse.statusCode == 200
          ? http.put(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
              body: jsonEncode(body),
            )
          : http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $accessToken',
              },
              body: jsonEncode(body),
            ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('profile_complete', true);
         // Also clear the needs_profile_setup_after_signup flag after successful setup
        await prefs.setBool('needs_profile_setup_after_signup', false);

        // Refresh the fetched profile data after successful submission
        await fetchUserProfile();

        return true;
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Profile setup failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile setup failed: $e')));
    }
    return false;
  }
} 
