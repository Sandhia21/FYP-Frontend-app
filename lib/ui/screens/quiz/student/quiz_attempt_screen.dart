import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/constants.dart';

import '../../../../providers/quiz_provider.dart';
import '../../../../providers/result_provider.dart';
import '../../../../widgets/common/app_bar.dart';
import '../../../../widgets/common/custom_button.dart';

import '../../../../widgets/quiz/quiz_question_view.dart';
import '../../../../data/models/quiz.dart';

import '../../../../services/routes.dart' as app_routes;
import '../../../../services/ai_service.dart';

class QuizAttemptScreen extends StatefulWidget {
  final int moduleId;
  final int quizId;

  const QuizAttemptScreen({
    super.key,
    required this.moduleId,
    required this.quizId,
  });

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isSubmitting = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _fetchQuizDetails();
    _checkAttemptCount();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchQuizDetails() async {
    final quizProvider = context.read<QuizProvider>();
    await quizProvider.fetchQuizDetails(widget.moduleId, widget.quizId);
  }

  Future<void> _checkAttemptCount() async {
    final quizProvider = context.read<QuizProvider>();
    final attemptInfo = await quizProvider.fetchAttemptInfo(
      widget.moduleId,
      widget.quizId,
    );

    if (mounted && !attemptInfo.canAttempt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum attempts reached for this quiz'),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _initializeAnswers(int questionCount) {
    final quizProvider = context.read<QuizProvider>();
    if (quizProvider.getUserAnswers(widget.quizId) == null) {
      final initialAnswers = List<int>.filled(questionCount, -1);
      quizProvider.updateAnswers(widget.quizId, initialAnswers);
    }
  }

  void _startQuiz() {
    final quizProvider = context.read<QuizProvider>();
    final quiz = quizProvider.selectedQuiz;
    if (quiz != null) {
      try {
        quizProvider.startQuizAttempt(widget.quizId);
        _initializeAnswers(quiz.parsedQuestions.length);
        setState(() {
          _hasStarted = true;
          _timeRemaining = quiz.quizDuration * 60;
        });
        _startTimer();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _timer?.cancel();
          _submitQuiz();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = (_timeRemaining / 60).floor();
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;

    final quizProvider = context.read<QuizProvider>();
    final userAnswers = quizProvider.getUserAnswers(widget.quizId);
    final quiz = quizProvider.selectedQuiz;

    if (userAnswers == null || quiz == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to submit quiz. Please try again.')),
        );
      }
      return;
    }

    // Check if at least one question is answered
    if (userAnswers.where((answer) => answer != -1).isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please answer at least one question')),
        );
      }
      return;
    }

    // Store context-dependent objects before async gap
    final navigatorContext = context;

    // Show confirmation dialog
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz?'),
        content: Text(
            'You have answered ${userAnswers.where((a) => a != -1).length} out of ${quiz.parsedQuestions.length} questions. Are you sure you want to submit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (shouldSubmit != true || !mounted) return;

    setState(() => _isSubmitting = true);
    _timer?.cancel();

    try {
      // Calculate score locally
      int correctAnswers = 0;
      final questions = quiz.parsedQuestions;
      final questionResults = <Map<String, dynamic>>[];

      for (int i = 0; i < questions.length; i++) {
        final isCorrect = i < userAnswers.length &&
            userAnswers[i] != -1 &&
            questions[i].isCorrectIndex(userAnswers[i]);

        if (isCorrect) correctAnswers++;

        questionResults.add({
          'question': questions[i].question,
          'correct': isCorrect,
          'user_answer': userAnswers[i] != -1
              ? questions[i].options[userAnswers[i]]
              : 'Not answered',
          'correct_answer':
              questions[i].options[questions[i].correctOptionIndex],
        });
      }

      final score = (correctAnswers / questions.length) * 100;

      // Generate AI recommendations
      String aiRecommendations;
      try {
        aiRecommendations = await AIService.generateRecommendations(
          quizResults: questionResults,
          subject: quiz.title,
        );
      } catch (e) {
        // Fallback if AI recommendations fail
        aiRecommendations = 'Unable to generate recommendations at this time.';
      }

      // Submit result to server
      final resultProvider = navigatorContext.read<ResultProvider>();
      await resultProvider.submitResult(
        moduleId: widget.moduleId,
        quizId: widget.quizId,
        percentage: score,
        quizContent: quiz.content,
        aiRecommendations: aiRecommendations,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        navigatorContext,
        app_routes.AppRoutes.quizResult,
        arguments: {
          'moduleId': widget.moduleId,
          'quizId': widget.quizId,
          'score': score,
          'userAnswers': userAnswers,
          'questions': questions,
          'correctCount': correctAnswers,
          'totalQuestions': questions.length,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildQuestionList(Quiz quiz, List<int>? userAnswers) {
    return ListView.builder(
      padding: const EdgeInsets.all(Dimensions.md),
      itemCount: quiz.parsedQuestions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.md),
          child: QuizQuestionView(
            question: quiz.parsedQuestions[index],
            questionNumber: index + 1,
            selectedOptionIndex: userAnswers?[index] ?? -1,
            onAnswerSelected: (selectedIndex) {
              final quizProvider = context.read<QuizProvider>();
              final currentAnswers = List<int>.from(userAnswers ?? []);

              // Ensure the list is large enough
              while (currentAnswers.length <= index) {
                currentAnswers.add(-1);
              }

              currentAnswers[index] = selectedIndex;
              quizProvider.updateAnswers(widget.quizId, currentAnswers);
            },
            showCorrectAnswer: false,
            isPreview: false,
            isResultView: false,
          ),
        );
      },
    );
  }

  Widget _buildStartQuizView(Quiz quiz, QuizProvider quizProvider) {
    final attemptInfo = quizProvider.getQuizAttemptInfo(quiz.id);

    if (attemptInfo == null) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              quiz.title,
              style: TextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.md),
            Text(
              quiz.description,
              style: TextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.xl),
            _buildQuizInfoCard(quiz),
            const SizedBox(height: Dimensions.xl),
            Text(
              'Attempts: ${attemptInfo.attemptsMade}/${attemptInfo.maxAttempts}',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (attemptInfo.remainingAttempts > 0) ...[
              Text(
                'Remaining attempts: ${attemptInfo.remainingAttempts}',
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
            const SizedBox(height: Dimensions.lg),
            CustomButton(
              text: 'Start Quiz',
              onPressed: attemptInfo.canAttempt ? _startQuiz : null,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizInfoCard(Quiz quiz) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Column(
          children: [
            _buildInfoRow('Duration', '${quiz.quizDuration} minutes'),
            const SizedBox(height: Dimensions.sm),
            _buildInfoRow('Questions', '${quiz.parsedQuestions.length}'),
            const SizedBox(height: Dimensions.sm),
            _buildInfoRow('Attempts Allowed', '${quiz.maxAttempts}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyles.bodyMedium),
        Text(value, style: TextStyles.bodyLarge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quiz',
        actions: [
          if (_hasStarted)
            Padding(
              padding: const EdgeInsets.only(right: Dimensions.md),
              child: Center(
                child: Text(
                  'Time: ${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                  style: TextStyles.bodyLarge,
                ),
              ),
            ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final quiz = quizProvider.selectedQuiz;
          if (quiz == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_hasStarted) {
            return _buildStartQuizView(quiz, quizProvider);
          }

          final userAnswers = quizProvider.getUserAnswers(widget.quizId);

          return Column(
            children: [
              Expanded(
                child: _buildQuestionList(quiz, userAnswers),
              ),
              _buildBottomBar(quiz, userAnswers),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(Quiz quiz, List<int>? userAnswers) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${userAnswers?.where((a) => a != -1).length ?? 0}/${quiz.parsedQuestions.length} Answered',
              style: TextStyles.bodyMedium,
            ),
          ),
          const SizedBox(width: Dimensions.md),
          CustomButton(
            text: 'Submit',
            onPressed: _isSubmitting ? null : _submitQuiz,
            isLoading: _isSubmitting,
            width: 120,
          ),
        ],
      ),
    );
  }
}
