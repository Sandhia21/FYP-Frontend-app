import 'package:dio/dio.dart';
import 'api_config.dart';

class ResultApiService {
  final Dio _dio;

  ResultApiService() : _dio = ApiConfig.dio;

  Future<List<dynamic>> fetchResults(int moduleId, int quizId) async {
    try {
      final response = await _dio.get('/results/$moduleId/quizzes/$quizId/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitResult({
    required int moduleId,
    required int quizId,
    required double percentage,
    required String quizContent,
  }) async {
    try {
      final response = await _dio.post(
        '/results/$moduleId/quizzes/$quizId/',
        data: {
          'percentage': percentage.toInt(),
          'quiz_content': quizContent,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getLeaderboard(int moduleId, int quizId) async {
    try {
      final response = await _dio.get(
        '/results/$moduleId/quizzes/$quizId/leaderboard/',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return 'Please login to access results';
      }
      if (e.response!.data is Map) {
        if (e.response!.data['code'] == 'duplicate_submission') {
          return 'You have already submitted this quiz';
        }
        return e.response!.data['detail'] ?? 'An error occurred';
      }
      return e.response!.statusMessage ?? 'An error occurred';
    }
    return e.message ?? 'Network error occurred';
  }
}
