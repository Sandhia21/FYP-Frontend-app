import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  //if running one emulator use the url below
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  // Create a single instance of Dio with BaseOptions
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 50),
      receiveTimeout: const Duration(seconds: 50),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Add auth token to all requests if it exists
            final token = await _secureStorage.read(key: _tokenKey);
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            print('Error reading token: $e');
            // Continue without token if there's an error
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              // Token expired or invalid
              await _secureStorage.delete(key: _tokenKey);
            } catch (e) {
              print('Error deleting token: $e');
            }
          }
          return handler.next(error);
        },
      ),
    );

  // Getter for the Dio instance
  static Dio get dio => _dio;

  // Methods to handle auth token
  static Future<void> setAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  static Future<void> removeAuthToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      // Also clear the refresh token
      await _secureStorage.delete(key: 'refresh_token');
      // Clear the Authorization header
      clearHeaders();
    } catch (e) {
      print('Error removing token: $e');
      rethrow;
    }
  }

  static Future<bool> hasToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token != null;
    } catch (e) {
      print('Error checking token: $e');
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  static void clearHeaders() {
    _dio.options.headers.remove('Authorization');
  }
}
