import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileSetupProvider extends ChangeNotifier {
  String? gender;
  int? workoutsPerWeek;
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

  void setWorkouts(int value) {
    workoutsPerWeek = value;
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

    _userProfileData = await AuthService().fetchProfile();

    _isFetchingProfile = false;
    print('Finished fetching user profile: $_userProfileData');
    notifyListeners();
  }

  // Method to update a specific profile field
  Future<bool> updateProfileField({required String fieldName, required dynamic fieldValue}) async {
     print('Updating profile field: $fieldName with value: $fieldValue');
    _isUpdatingProfile = true;
    notifyListeners();

    final success = await AuthService().updateProfileFieldApi(fieldName: fieldName, fieldValue: fieldValue);

    _isUpdatingProfile = false;
    if (success) {
      print('Profile field updated successfully.');
      // Refresh local profile data after successful update
      await fetchUserProfile();
      // Show a success message (optional, can be handled in UI)
       return true;
    } else {
      print('Profile field update failed.');
       // Show an error message (optional, can be handled in UI)
      return false;
    }
  }

  Future<bool> submitProfile(BuildContext context) async {
    final accessToken = await AuthService().getAccessToken();
    if (accessToken == null) return false;
    final url = Uri.parse('${AuthService().baseUrl}/api/v1/profile/');

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
        "workout_per_week": workoutsPerWeek ?? 3,
        // You might need to add goal related fields here if they are part of initial setup
        // For now, using dummy values as in previous edit
         "goal": "Lose fat and build lean muscle",
        "goal_weight": 68,
        "weekly_weight_speed": 0.5,
        "user_goal_obstacles":
            "Struggles with late-night snacking and inconsistent workout schedule",
        "user_goal_achievements": true,
        "specific_diet": "High protein, low carb",
        "user_accomplishments":
            "Completed a 5K run, lost 3 kg in the last 2 months",
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
