import '../models/quiz.dart';
import '../../services/quiz_api_service.dart';
import 'package:logging/logging.dart';
import '../models/quiz_attempt_info.dart';

class QuizRepository {
  final QuizApiService _quizService;
  final _logger = Logger('QuizRepository');

  QuizRepository(this._quizService);

  Future<List<Quiz>> getQuizzes(int moduleId) async {
    try {
      return await _quizService.fetchQuizzes(moduleId);
    } catch (e) {
      _logger.severe('Error fetching quizzes: $e');
      throw _handleRepositoryError(e);
    }
  }

  Future<Quiz> getQuizDetail({
    required int moduleId,
    required int quizId,
  }) async {
    try {
      return await _quizService.getQuizDetail(moduleId, quizId);
    } catch (e) {
      _logger.severe('Error fetching quiz detail: $e');
      throw _handleRepositoryError(e);
    }
  }

  Future<Quiz> createQuiz({
    required int moduleId,
    required String title,
    required String description,
    required String content,
    required String quizDuration,
    bool? fromAi,
    String? note,
    int? maxAttempts,
  }) async {
    try {
      return await _quizService.createQuiz(
        moduleId: moduleId,
        title: title,
        description: description,
        content: content,
        duration: int.parse(quizDuration),
        fromAi: fromAi ?? false,
        note: note,
        maxAttempts: maxAttempts ?? 1,
      );
    } catch (e) {
      _logger.severe('Error creating quiz: $e');
      throw _handleRepositoryError(e);
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
      return await _quizService.updateQuiz(
        moduleId: moduleId,
        quizId: quizId,
        title: title,
        description: description,
        content: content,
        duration: duration,
        note: note,
        maxAttempts: maxAttempts,
      );
    } catch (e) {
      _logger.severe('Error updating quiz: $e');
      throw _handleRepositoryError(e);
    }
  }

  Future<void> deleteQuiz({
    required int moduleId,
    required int quizId,
  }) async {
    try {
      await _quizService.deleteQuiz(
        moduleId: moduleId,
        quizId: quizId,
      );
    } catch (e) {
      _logger.severe('Error deleting quiz: $e');
      throw _handleRepositoryError(e);
    }
  }

  Future<Quiz> updateQuizContent({
    required int moduleId,
    required int quizId,
    required String content,
  }) async {
    try {
      return await _quizService.updateQuizContent(
        moduleId: moduleId,
        quizId: quizId,
        content: content,
      );
    } catch (e) {
      _logger.severe('Error updating quiz content: $e');
      throw _handleRepositoryError(e);
    }
  }

  Future<int> getQuizAttemptCount({
    required int moduleId,
    required int quizId,
  }) async {
    try {
      return await _quizService.getQuizAttemptCount(
        moduleId: moduleId,
        quizId: quizId,
      );
    } catch (e) {
      _logger.severe('Error getting quiz attempt count: $e');
      throw _handleRepositoryError(e);
    }
  }

  Future<QuizAttemptInfo> getQuizAttemptInfo({
    required int moduleId,
    required int quizId,
  }) async {
    try {
      return await _quizService.getQuizAttemptInfo(moduleId, quizId);
    } catch (e) {
      _logger.severe('Error fetching quiz attempt info: $e');
      throw _handleRepositoryError(e);
    }
  }

  String _handleRepositoryError(dynamic error) {
    if (error is String) {
      switch (error.toLowerCase()) {
        case 'quiz not found':
          return 'The requested quiz does not exist';
        case 'permission denied':
          return 'You do not have permission to access this quiz';
        case 'network error occurred':
          return 'Please check your internet connection';
        case 'maximum attempts reached':
          return 'You have reached the maximum number of attempts for this quiz';
        case 'quiz update failed':
          return 'Failed to update the quiz';
        case 'quiz delete failed':
          return 'Failed to delete the quiz';
        default:
          return error;
      }
    }
    return error.toString();
  }
}
