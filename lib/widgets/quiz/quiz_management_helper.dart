import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../data/models/quiz.dart';
import '../../data/models/parsed_questions.dart';
import 'question_form_dialog.dart';
import '../../constants/constants.dart';

class QuizManagementHelper {
  static Future<void> handleEditQuestion({
    required BuildContext context,
    required Quiz quiz,
    required int questionIndex,
    required Function onQuizUpdated,
  }) async {
    final question = quiz.parsedQuestions[questionIndex];
    final result = await showDialog<ParsedQuestion>(
      context: context,
      builder: (context) => QuestionFormDialog(
        initialQuestion: question,
        isEditing: true,
        onSave: (ParsedQuestion edited) async {
          final quizProvider =
              Provider.of<QuizProvider>(context, listen: false);
          final updatedQuestions =
              List<ParsedQuestion>.from(quiz.parsedQuestions);
          updatedQuestions[questionIndex] = edited;

          await quizProvider.updateQuiz(
            moduleId: quiz.moduleId,
            quizId: quiz.id,
            title: quiz.title,
            description: quiz.description,
            questions: updatedQuestions,
            duration: quiz.quizDuration,
            maxAttempts: quiz.maxAttempts,
          );

          onQuizUpdated();
        },
      ),
    );
  }

  static Future<void> handleDeleteQuestion({
    required BuildContext context,
    required Quiz quiz,
    required int questionIndex,
    required Function onQuizUpdated,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        final updatedQuestions = List<ParsedQuestion>.from(quiz.parsedQuestions)
          ..removeAt(questionIndex);

        await quizProvider.updateQuiz(
          moduleId: quiz.moduleId,
          quizId: quiz.id,
          title: quiz.title,
          description: quiz.description,
          questions: updatedQuestions,
          duration: quiz.quizDuration,
          maxAttempts: quiz.maxAttempts,
        );

        onQuizUpdated();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  static Future<void> handleDeleteQuiz({
    required BuildContext context,
    required Quiz quiz,
    required Function onSuccess,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${quiz.title}"?'),
            const SizedBox(height: Dimensions.md),
            Text(
              'This will also delete all student attempts and results.',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.error,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        await quizProvider.deleteQuiz(quiz.moduleId, quiz.id);
        onSuccess();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }
}
