import 'package:dio/dio.dart';
import 'api_config.dart';

class EnrollmentApiService {
  final Dio _dio;

  EnrollmentApiService() : _dio = ApiConfig.dio;

  Future<List<dynamic>> fetchTeacherEnrollmentRequests() async {
    try {
      final response = await _dio.get('/enrollments/teacher/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> fetchStudentEnrollmentRequests() async {
    try {
      final response = await _dio.get('/enrollments/student-requests/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> respondToEnrollment(int requestId, bool isApproved) async {
    try {
      await _dio.post('/enrollments/$requestId/respond/', data: {
        'is_approved': isApproved,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> enrollInCourse(
      int courseId, String courseCode) async {
    try {
      print('Attempting to enroll in course: $courseId with code: $courseCode');

      final response = await _dio.post(
        '/enrollments/create/',
        data: {
          'course_id': courseId,
          'course_code': courseCode,
        },
      );

      print('Enrollment response: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'status': 'success',
          'detail':
              response.data['detail'] ?? 'Successfully enrolled in course',
          ...response.data,
        };
      }

      return response.data;
    } on DioException catch (e) {
      print('Enrollment error: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final responseData = e.response!.data;

      // Handle different status codes
      switch (e.response!.statusCode) {
        case 400:
          if (responseData is Map) {
            if (responseData['detail']
                    ?.toString()
                    .toLowerCase()
                    .contains('already enrolled') ==
                true) {
              return 'already enrolled';
            }
            return responseData['detail'] ?? 'Invalid request';
          }
          return 'Invalid request';
        case 401:
          return 'Please login to manage enrollments';
        case 403:
          return 'Permission denied';
        case 404:
          return 'Course not found';
        case 409:
          return 'Already enrolled';
        case 429:
          return 'Too many enrollment attempts. Please try again later';
      }

      // Handle response data
      if (responseData is Map) {
        final detail = responseData['detail']?.toString().toLowerCase() ?? '';

        if (detail.contains('already enrolled')) {
          return 'already enrolled';
        }
        if (detail.contains('invalid code')) {
          return 'invalid course code';
        }
        if (detail.contains('full')) {
          return 'course full';
        }

        return responseData['detail'] ?? 'An error occurred';
      }

      return e.response!.statusMessage ?? 'An error occurred';
    }

    return e.message ?? 'Network error occurred';
  }
}
