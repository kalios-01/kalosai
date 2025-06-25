import 'package:flutter/material.dart';
import 'package:kalos_ai/services/google_auth_service.dart';
import 'package:kalos_ai/models/food_item.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class FoodHistoryProvider with ChangeNotifier {
  final GoogleAuthService _authService;
  List<FoodItem> _foodHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FoodItem> get foodHistory => _foodHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FoodHistoryProvider(this._authService);

  Future<void> fetchFoodHistory({DateTime? date}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      String endpoint = '/api/v1/food/history';
      if (date != null) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        endpoint += '?upload_date=$formattedDate';
      }
      
      final response = await http.get(
        Uri.parse('${_authService.baseUrl}$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        _foodHistory = data.map((json) => FoodItem.fromJson(json)).toList();
        _errorMessage = null;
        print('Food history fetched: ${_foodHistory.length} items');
      } else if (response.statusCode == 404) {
        _foodHistory = [];
        _errorMessage = null;
        print('No food entries for this date. Status 404. Response body: ${response.body}');
      } else {
        _errorMessage = 'Failed to load food history: ${response.statusCode}';
        print(_errorMessage);
        print('Food history API response body: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Error fetching food history: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteFoodItem(int foodId) async {
    _errorMessage = null;
    print('Attempting to delete food item with ID: $foodId');

    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        print('No access token available for deletion');
        return false;
      }

      final response = await http.delete(
        Uri.parse('${_authService.baseUrl}/api/v1/food/$foodId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Food item $foodId deleted successfully on server.');
        return true;
      } else {
        print('Failed to delete food item: ${response.statusCode}');
        print('Delete food item API response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting food item: $e');
      return false;
    }
  }
} 