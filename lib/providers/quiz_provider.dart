import 'package:flutter/foundation.dart';
import '../data/models/quiz.dart';
import '../data/models/parsed_questions.dart';
import '../data/repositories/quiz_repository.dart';
import '../widgets/quiz/quiz_format_controller.dart';
import '../services/ai_service.dart';
import '../data/models/quiz_attempt_info.dart';

class QuizProvider extends ChangeNotifier {
  final QuizRepository _repository;
  final QuizFormatController _formatController = QuizFormatController();

  // State management
  List<Quiz> _quizzes = [];
  Quiz? _selectedQuiz;
  bool _isLoading = false;
  String? _error;

  // Quiz attempt state
  Map<int, List<int>> _userAnswers = {}; // quizId -> [answerIndices]
  Map<int, double> _quizScores = {}; // quizId -> score
  Map<int, int> _quizAttempts = {}; // quizId -> attemptCount

  // Add this field
  Map<int, QuizAttemptInfo> _quizAttemptInfo = {};

  QuizProvider(this._repository);

  // Getters
  List<Quiz> get quizzes => _quizzes;
  Quiz? get selectedQuiz => _selectedQuiz;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ParsedQuestion> get currentQuestions =>
      _selectedQuiz?.parsedQuestions ?? [];
  List<int>? getUserAnswers(int quizId) => _userAnswers[quizId];
  double? getQuizScore(int quizId) => _quizScores[quizId];
  int getAttemptCount(int quizId) => _quizAttempts[quizId] ?? 0;

  // Add this getter
  QuizAttemptInfo? getQuizAttemptInfo(int quizId) => _quizAttemptInfo[quizId];

  // Teacher Functions
  Future<void> createQuiz({
    required int moduleId,
    required String title,
    required String description,
    required List<ParsedQuestion> questions,
    required int duration,
    bool isAIGenerated = false,
    String? note,
    int maxAttempts = 1,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final content = _formatController.formatQuizContent(questions);
      final quiz = await _repository.createQuiz(
        moduleId: moduleId,
        title: title,
        description: description,
        content: content,
        quizDuration: duration.toString(),
        fromAi: isAIGenerated,
        note: note,
        maxAttempts: maxAttempts,
      );

      _quizzes.add(quiz);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateQuiz({
    required int moduleId,
    required int quizId,
    String? title,
    String? description,
    List<ParsedQuestion>? questions,
    int? duration,
    String? note,
    int? maxAttempts,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      String? content;
      if (questions != null) {
        content = _formatController.formatQuizContent(questions);
      }

      final updatedQuiz = await _repository.updateQuiz(
        moduleId: moduleId,
        quizId: quizId,
        title: title,
        description: description,
        content: content,
        duration: duration,
        note: note,
        maxAttempts: maxAttempts,
      );

      final index = _quizzes.indexWhere((q) => q.id == quizId);
      if (index != -1) {
        _quizzes[index] = updatedQuiz;
      }
      if (_selectedQuiz?.id == quizId) {
        _selectedQuiz = updatedQuiz;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Student Functions
  Future<void> startQuizAttempt(int quizId) async {
    if (_selectedQuiz == null) return;

    try {
      final attemptCount = await _repository.getQuizAttemptCount(
        moduleId: _selectedQuiz!.moduleId,
        quizId: quizId,
      );

      if (attemptCount >= _selectedQuiz!.maxAttempts) {
        throw 'Maximum attempts reached for this quiz';
      }

      _userAnswers[quizId] =
          List.filled(_selectedQuiz!.parsedQuestions.length, -1);
      _quizScores.remove(quizId);
      _quizAttempts[quizId] = attemptCount;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Common Functions
  Future<void> fetchQuizzes(int moduleId) async {
    try {
      _setLoading(true);
      _quizzes = await _repository.getQuizzes(moduleId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchQuizDetails(int moduleId, int quizId) async {
    try {
      _setLoading(true);
      _selectedQuiz = await _repository.getQuizDetail(
        moduleId: moduleId,
        quizId: quizId,
      );

      // Also fetch attempt count when getting quiz details
      await fetchAttemptCount(moduleId, quizId);

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAttemptCount(int moduleId, int quizId) async {
    try {
      final count = await _repository.getQuizAttemptCount(
        moduleId: moduleId,
        quizId: quizId,
      );
      _quizAttempts[quizId] = count;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void updateAnswers(int quizId, List<int> answers) {
    _userAnswers[quizId] = answers;
    notifyListeners();
  }

  // Add deleteQuiz method
  Future<void> deleteQuiz(int moduleId, int quizId) async {
    try {
      _setLoading(true);
      _error = null;

      await _repository.deleteQuiz(
        moduleId: moduleId,
        quizId: quizId,
      );

      // Remove quiz from local state
      _quizzes.removeWhere((quiz) => quiz.id == quizId);
      if (_selectedQuiz?.id == quizId) {
        _selectedQuiz = null;
      }

      // Clean up related state
      _userAnswers.remove(quizId);
      _quizScores.remove(quizId);
      _quizAttempts.remove(quizId);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // AI Quiz Generation
  Future<List<ParsedQuestion>> generateQuestionsWithAI({
    required String topic,
    required String difficulty,
    required int numQuestions,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      // Get raw quiz content from AI service
      final rawQuizContent = await AIService.generateQuiz(
        topic: topic,
        numberOfQuestions: numQuestions,
        difficulty: difficulty,
      );

      // Parse the raw content into structured questions
      final questions = _formatController.parseQuizContent(rawQuizContent);

      if (questions.isEmpty) {
        throw Exception(
            'Failed to generate valid questions. Please try again.');
      }

      return questions;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Add this method
  Future<QuizAttemptInfo> fetchAttemptInfo(int moduleId, int quizId) async {
    try {
      _setLoading(true);
      final attemptInfo = await _repository.getQuizAttemptInfo(
        moduleId: moduleId,
        quizId: quizId,
      );
      _quizAttemptInfo[quizId] = attemptInfo;
      notifyListeners();
      return attemptInfo;
    } finally {
      _setLoading(false);
    }
  }
}
