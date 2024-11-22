import 'package:dio/dio.dart';
import 'api_config.dart';

class CourseApiService {
  final Dio _dio;

  CourseApiService() : _dio = ApiConfig.dio;

  Future<List<dynamic>> fetchCourses() async {
    try {
      final response = await _dio.get('/courses/');
      if (response.statusCode == 200) {
        print('Fetch Courses Response: ${response.data}'); // For debugging
        return response.data;
      } else {
        throw 'Failed to fetch courses';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCourseDetail(int courseId) async {
    try {
      final response = await _dio.get('/courses/$courseId/');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw 'Failed to get course details';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createCourse(
      Map<String, dynamic> courseData) async {
    try {
      final response = await _dio.post(
        '/courses/',
        data: courseData,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw 'Failed to create course';
      }
    } on DioException catch (e) {
      print('Create Course Error: ${e.response?.data}'); // For debugging
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateCourse(
      int courseId, Map<String, dynamic> courseData) async {
    try {
      final response = await _dio.put(
        '/courses/$courseId/',
        data: courseData,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw 'Failed to update course';
      }
    } on DioException catch (e) {
      print('Update Course Error: ${e.response?.data}'); // For debugging
      throw _handleError(e);
    }
  }

  Future<void> deleteCourse(int courseId) async {
    try {
      final response = await _dio.delete('/courses/$courseId/');
      if (response.statusCode != 204) {
        throw 'Failed to delete course';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return 'Please login to access this content';
      }
      if (e.response!.data is Map) {
        final error = e.response!.data['detail'] ?? e.response!.data['error'];
        if (error != null) return error.toString();
      }
      return e.response!.statusMessage ?? 'An error occurred';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timed out';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Please check your internet connection';
    }
    return 'Network error occurred';
  }
}
