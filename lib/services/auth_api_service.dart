import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class AuthApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthApiService()
      : _dio = ApiConfig.dio,
        _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/users/login/', data: {
        'username': username,
        'password': password,
      });

      // Store tokens securely
      if (response.data['access'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['access']);
      }
      if (response.data['refresh'] != null) {
        await _storage.write(
            key: 'refresh_token', value: response.data['refresh']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
  }) async {
    try {
      await _dio.post('/users/register/', data: {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/token/refresh/', data: {
        'refresh': refreshToken,
      });

      // Store new access token
      if (response.data['access'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['access']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout/');
      // Clear stored tokens
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String?> getStoredToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<String?> getStoredRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        // Clear tokens on authentication error
        _storage.delete(key: 'auth_token');
        _storage.delete(key: 'refresh_token');
        return 'Authentication failed. Please login again.';
      }

      if (e.response!.data is Map) {
        return e.response!.data['detail'] ?? 'An error occurred';
      }
      return e.response!.statusMessage ?? 'An error occurred';
    }
    return e.message ?? 'Network error occurred';
  }

  Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      print('Sending profile update request with data:');
      print({
        'username': username,
        'email': email,
        'first_name': firstName ?? '',
        'last_name': lastName ?? '',
      });

      final response = await _dio.patch(
        '/users/profile/',
        data: {
          'username': username,
          'email': email,
          'first_name': firstName ?? '',
          'last_name': lastName ?? '',
        },
      );

      print('Received response:');
      print(response.data);

      if (response.data == null) {
        throw 'Empty response received';
      }

      return response.data;
    } on DioException catch (e) {
      print('DioException occurred:');
      print('Error: ${e.error}');
      print('Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      print('Other error occurred:');
      print(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfileImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.patch(
        '/users/profile/',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/profile/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
