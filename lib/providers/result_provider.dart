import 'package:flutter/foundation.dart';
import '../data/models/result.dart';
import '../data/repositories/result_repository.dart';

class ResultProvider extends ChangeNotifier {
  final ResultRepository _repository;
  List<Result> _results = [];
  Map<String, dynamic>? _leaderboard;
  bool _isLoading = false;
  String? _error;

  ResultProvider(this._repository);

  List<Result> get results => _results;
  Map<String, dynamic>? get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchResults(int moduleId, int quizId) async {
    try {
      _setLoading(true);
      _results = await _repository.getResults(moduleId, quizId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitResult({
    required int moduleId,
    required int quizId,
    required double percentage,
    required String quizContent,
  }) async {
    try {
      _setLoading(true);
      final result = await _repository.submitResult(
        moduleId: moduleId,
        quizId: quizId,
        percentage: percentage,
        quizContent: quizContent,
      );
      _results = [result, ..._results];
      _error = null;
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchLeaderboard(int moduleId, int quizId) async {
    try {
      _setLoading(true);
      _leaderboard = await _repository.getLeaderboard(moduleId, quizId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
