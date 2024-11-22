import 'package:dio/dio.dart';
import '../data/models/quiz.dart';
import 'api_config.dart';
import '../data/models/quiz_attempt_info.dart';

class QuizApiService {
  final Dio _dio;

  QuizApiService() : _dio = ApiConfig.dio;

  Future<List<Quiz>> fetchQuizzes(int moduleId) async {
    try {
      final response = await _dio.get('/modules/$moduleId/quizzes/');
      return (response.data as List)
          .map((quiz) => Quiz.fromJson(quiz))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Quiz> getQuizDetail(int moduleId, int quizId) async {
    try {
      final response = await _dio.get('/modules/$moduleId/quizzes/$quizId/');
      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Quiz> createQuiz({
    required int moduleId,
    required String title,
    required String description,
    required String content,
    required int duration,
    bool fromAi = false,
    String? note,
    int maxAttempts = 1,
  }) async {
    try {
      final response = await _dio.post(
        '/modules/$moduleId/quizzes/',
        data: {
          'title': title,
          'module': moduleId,
          'description': description,
          'content': content,
          'quiz_duration': duration,
          'from_ai': fromAi,
          'note': note,
          'max_attempts': maxAttempts,
        },
      );
      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Quiz> updateQuiz({
    required int moduleId,
    required int quizId,
    String? title,
    String? description,
    String? content,
    int? duration,
    String? note,
    int? maxAttempts,
  }) async {
    try {
      final response = await _dio.patch(
        '/modules/$moduleId/quizzes/$quizId/',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (content != null) 'content': content,
          if (duration != null) 'quiz_duration': duration,
          if (note != null) 'note': note,
          if (maxAttempts != null) 'max_attempts': maxAttempts,
        },
      );
      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteQuiz({
    required int moduleId,
    required int quizId,
  }) async {
    try {
      await _dio.delete('/modules/$moduleId/quizzes/$quizId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Quiz> updateQuizContent({
    required int moduleId,
    required int quizId,
    required String content,
  }) async {
    try {
      final response = await _dio.put(
        '/modules/$moduleId/quizzes/$quizId/',
        data: {
          'content': content,
          'module': moduleId,
        },
      );
      return Quiz.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<int> getQuizAttemptCount({
    required int moduleId,
    required int quizId,
  }) async {
    try {
      final response = await _dio.get(
        '/modules/$moduleId/quizzes/$quizId/attempts/',
      );
      return response.data['attempt_count'] ?? 0;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<QuizAttemptInfo> getQuizAttemptInfo(int moduleId, int quizId) async {
    try {
      final response = await _dio.get(
        '/modules/$moduleId/quizzes/$quizId/attempts/',
      );
      return QuizAttemptInfo.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return 'Please login to access quiz content';
      }
      if (e.response!.statusCode == 403) {
        return 'Maximum attempts reached for this quiz';
      }
      if (e.response!.data is Map) {
        return e.response!.data['detail'] ?? 'An error occurred';
      }
      return e.response!.statusMessage ?? 'An error occurred';
    }
    return e.message ?? 'Network error occurred';
  }
}
