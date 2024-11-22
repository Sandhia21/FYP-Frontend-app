import '../models/result.dart';
import '../../services/result_api_service.dart';

class ResultRepository {
  final ResultApiService _resultService;

  ResultRepository(this._resultService);

  Future<List<Result>> getResults(int moduleId, int quizId) async {
    try {
      final response = await _resultService.fetchResults(moduleId, quizId);
      return response.map((resultJson) => Result.fromJson(resultJson)).toList();
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<Result> submitResult({
    required int moduleId,
    required int quizId,
    required double percentage,
    required String quizContent,
  }) async {
    try {
      final response = await _resultService.submitResult(
        moduleId: moduleId,
        quizId: quizId,
        percentage: percentage,
        quizContent: quizContent,
      );
      return Result.fromJson(response);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<Map<String, dynamic>> getLeaderboard(int moduleId, int quizId) async {
    try {
      return await _resultService.getLeaderboard(moduleId, quizId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  String _handleRepositoryError(dynamic error) {
    if (error is String) {
      switch (error.toLowerCase()) {
        case 'result not found':
          return 'The requested result does not exist';
        case 'permission denied':
          return 'You do not have permission to access this result';
        case 'network error occurred':
          return 'Please check your internet connection';
        case 'you have already submitted this quiz':
          return 'You have already submitted this quiz';
        case 'quiz not found':
          return 'The quiz associated with this result does not exist';
        default:
          return error;
      }
    }
    return error.toString();
  }
}
