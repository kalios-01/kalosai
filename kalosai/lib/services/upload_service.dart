import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kalos_ai/services/google_auth_service.dart';

class UploadService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleAuthService _authService = GoogleAuthService();

  UploadService() {
    _dio.options.baseUrl = _authService.baseUrl;
  }

  Future<Map<String, dynamic>> _uploadImage(
    String endpoint,
    File imageFile,
    String imageFieldName,
  ) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        return {'success': false, 'message': 'Authentication required.'};
      }

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        imageFieldName: await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final fullUrl = '${_authService.baseUrl}$endpoint';
      print('Uploading image to: $fullUrl');
      print('Image file name: $fileName');

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/form-data',
        }),
      );

      print('Image upload successful! Status code: ${response.statusCode}');
      print('Response data: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('Dio error uploading image to $endpoint: ${e.message}');
      print('Request URL: ${e.requestOptions.uri}');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      return {'success': false, 'message': e.response?.data['message'] ?? 'Upload failed.'};
    } catch (e) {
      print('Error uploading image to $endpoint: $e');
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<Map<String, dynamic>> uploadBarcodeImage(File imageFile) async {
    return _uploadImage('/api/v1/barcode/scan', imageFile, 'file');
  }

  Future<Map<String, dynamic>> uploadFoodImage(File imageFile) async {
    return _uploadImage('/api/v1/food/upload', imageFile, 'file');
  }
} 