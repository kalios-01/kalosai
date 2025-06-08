import 'package:flutter/material.dart';
import 'package:kalai/services/auth_service.dart';
import 'package:kalai/models/food_item.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class FoodHistoryProvider with ChangeNotifier {
  final AuthService _authService;
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
      String endpoint = '/api/v1/food/history';
      if (date != null) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        endpoint += '?upload_date=$formattedDate';
      }
      print('Fetching food history from URL: ${_authService.baseUrl}$endpoint');
      final response = await _authService.get(endpoint);
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
      final response = await _authService.delete('/api/v1/food/$foodId');
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