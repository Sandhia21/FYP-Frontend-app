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
    String? aiRecommendations,
  }) async {
    try {
      final response = await _dio.post(
        '/results/$moduleId/quizzes/$quizId/',
        data: {
          'percentage': percentage.toInt(),
          'quiz_content': quizContent,
          if (aiRecommendations != null)
            'ai_recommendations': aiRecommendations,
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

  Future<Map<String, dynamic>> getResultDetails(
      int moduleId, int quizId, int resultId) async {
    try {
      final response = await _dio.get(
        '/results/$moduleId/quizzes/$quizId/results/$resultId/',
      );

      if (response.data == null) {
        throw 'Result not found';
      }

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
      if (e.response!.statusCode == 404) {
        return 'Result not found';
      }
      if (e.response!.statusCode == 403) {
        return 'Permission denied';
      }
      if (e.response!.data is Map) {
        if (e.response!.data['error'] == 'Maximum attempts reached') {
          return 'You have reached the maximum number of attempts for this quiz';
        }
        return e.response!.data['error'] ??
            e.response!.data['detail'] ??
            'An error occurred';
      }
      return e.response!.statusMessage ?? 'An error occurred';
    }
    return e.message ?? 'Network error occurred';
  }
}
