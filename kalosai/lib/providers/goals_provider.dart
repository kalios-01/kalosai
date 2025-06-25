import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GoalsProvider extends ChangeNotifier {
  final GoogleAuthService _authService = GoogleAuthService();
  double calories = 0.0;
  double fat = 0.0;
  double protein = 0.0;
  double carbs = 0.0;
  bool isLoading = false;
  String? error;

  Future<void> fetchGoals({DateTime? date}) async {
    print('Fetching goals...');
    isLoading = true;
    error = null;
    notifyListeners();

    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      print('No access token found');
      error = 'Not authenticated';
      isLoading = false;
      notifyListeners();
      return;
    }

    // Log the access token being sent
    print('🔑 Access Token being sent to server:');
    print('Token: $accessToken');
    print('Token length: ${accessToken.length}');
    print('Token preview: ${accessToken.substring(0, min(50, accessToken.length))}...');

    // Format the date if provided
    String? formattedDate;
    if (date != null) {
      formattedDate = DateFormat('yyyy-MM-dd').format(date);
    }

    // Construct the URL with date parameter if available
    Uri url = Uri.parse('${_authService.baseUrl}/api/v1/goals/goal_by_date');
    if (formattedDate != null) {
      url = url.replace(queryParameters: {'goal_date': formattedDate});
    }

    try {
      print('🌐 Making API request to: $url');
      print('📤 Request headers:');
      print('  Content-Type: application/json');
      print('  Authorization: Bearer ${accessToken.substring(0, min(20, accessToken.length))}...');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',

        },
      );
      print('📥 API response status: ${response.statusCode}');
      print('📥 API response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        calories = (data['calories'] ?? 0.0).toDouble();
        fat = (data['fat'] ?? 0.0).toDouble();
        protein = (data['protein'] ?? 0.0).toDouble();
        carbs = (data['carbs'] ?? 0.0).toDouble();
        print('✅ Goals updated: calories=$calories, fat=$fat, protein=$protein, carbs=$carbs');
      } else {
        error = 'Failed to fetch goals: ${response.statusCode}';
        print('❌ Error fetching goals: $error');
      }
    } catch (e) {
      error = 'Error: $e';
      print('❌ Exception fetching goals: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  // Method to manually refresh goals
  Future<void> refreshGoals({DateTime? date}) async {
    print('Manually refreshing goals...');
    await fetchGoals(date: date);
  }

  Future<void> updateGoals({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final accessToken = await _authService.getAccessToken();
    if (accessToken == null) {
      error = 'Not authenticated';
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('${_authService.baseUrl}/api/v1/goals/');
    final body = jsonEncode({
      'calories': calories,
      'fat': fat,
      'protein': protein,
      'carbs': carbs,
    });

    try {
      print('Updating goals at: $url');
      print('Request body: $body');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );
      print('API response status: ${response.statusCode}');
      print('API response body: ${response.body}');

      if (response.statusCode == 200) {
        // After successful update, fetch the latest goals to ensure consistency
        await fetchGoals(); 
        print('Goals updated successfully on server and refreshed locally.');
      } else {
        error = 'Failed to update goals: ${response.statusCode} - ${response.body}';
        print('Error updating goals: $error');
      }
    } catch (e) {
      error = 'Exception updating goals: $e';
      print('Exception updating goals: $e');
    }
    isLoading = false;
    notifyListeners();
  }
} 