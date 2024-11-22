import 'package:dio/dio.dart';
import 'api_config.dart';

class ModuleApiService {
  final Dio _dio;

  ModuleApiService() : _dio = ApiConfig.dio;

  Future<List<dynamic>> fetchModules(int courseId) async {
    try {
      final response =
          await _dio.get('/modules/', queryParameters: {'course_id': courseId});
      print(
          'Fetching modules from: ${_dio.options.baseUrl}/modules/?course_id=$courseId');
      print('Raw API Response: ${response.data}');

      if (response.data is List) {
        return response.data as List<dynamic>;
      } else if (response.data is Map && response.data['results'] is List) {
        return response.data['results'] as List<dynamic>;
      } else if (response.data is Map && response.data['modules'] is List) {
        return response.data['modules'] as List<dynamic>;
      } else {
        print('Unexpected response format: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Request URL: ${e.requestOptions.uri}');
      print('Query Parameters: ${e.requestOptions.queryParameters}');

      if (e.response?.statusCode == 404) {
        print('No modules found for course $courseId');
        return [];
      }
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> fetchModuleDetails(int moduleId) async {
    try {
      final response = await _dio.get('/modules/$moduleId/');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createModule(
      int courseId, String title, String description) async {
    try {
      print('Creating module for course $courseId');
      final response = await _dio.post('/modules/', data: {
        'course': courseId,
        'title': title,
        'description': description,
      });
      print('Create module response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('Error creating module: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateModule(
      int moduleId, String title, String description, int courseId) async {
    try {
      final response = await _dio.put(
        '/modules/$moduleId/',
        data: {
          'title': title,
          'description': description,
          'course': courseId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteModule(int moduleId) async {
    try {
      await _dio.delete('/modules/$moduleId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return 'Please login to access module content';
      }
      if (e.response!.data is Map) {
        return e.response!.data['detail'] ?? 'An error occurred';
      }
      return e.response!.statusMessage ?? 'An error occurred';
    }
    return e.message ?? 'Network error occurred';
  }
}
