import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/quiz/quiz_question_view.dart';
import '../../../constants/button_variant.dart';
import '../../../data/models/parsed_questions.dart';
import '../../../services/routes.dart' as app_routes;

class QuizResultScreen extends StatelessWidget {
  final int moduleId;
  final int quizId;
  final double score;
  final List<int> userAnswers;
  final List<ParsedQuestion> questions;
  final int correctCount;
  final int totalQuestions;

  const QuizResultScreen({
    super.key,
    required this.moduleId,
    required this.quizId,
    required this.score,
    required this.userAnswers,
    required this.questions,
    required this.correctCount,
    required this.totalQuestions,
  });

  String get _scoreMessage {
    if (score >= 90) return 'Excellent! You\'ve mastered this topic! 🏆';
    if (score >= 80) return 'Great job! You have a solid understanding! 🌟';
    if (score >= 70) return 'Good work! Keep practicing to improve! 👍';
    if (score >= 60) return 'You passed! Review the topics you missed. 📚';
    return 'Keep practicing! You\'ll improve with more study. 💪';
  }

  Color get _scoreColor {
    if (score >= 90) return AppColors.success;
    if (score >= 70) return AppColors.primary;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  IconData get _scoreIcon {
    if (score >= 90) return Icons.emoji_events;
    if (score >= 80) return Icons.star;
    if (score >= 70) return Icons.thumb_up;
    if (score >= 60) return Icons.check_circle;
    return Icons.refresh;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Quiz Results'),
      body: Column(
        children: [
          // Score Summary Card
          Card(
            margin: const EdgeInsets.all(Dimensions.md),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _scoreColor.withOpacity(0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_scoreIcon, color: _scoreColor, size: 32),
                      const SizedBox(width: Dimensions.md),
                      Text(
                        '${score.toStringAsFixed(1)}%',
                        style: TextStyles.h2.copyWith(color: _scoreColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.md),
                  Text(
                    _scoreMessage,
                    style: TextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard(
                        'Correct',
                        correctCount.toString(),
                        AppColors.success,
                      ),
                      const SizedBox(width: Dimensions.md),
                      _buildStatCard(
                        'Total',
                        totalQuestions.toString(),
                        AppColors.primary,
                      ),
                      const SizedBox(width: Dimensions.md),
                      _buildStatCard(
                        'Incorrect',
                        (totalQuestions - correctCount).toString(),
                        AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Questions Review
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.md,
                vertical: Dimensions.sm,
              ),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final userAnswer =
                    index < userAnswers.length ? userAnswers[index] : -1;
                final isCorrect =
                    userAnswer != -1 && question.isCorrectIndex(userAnswer);

                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.md),
                  child: QuizQuestionView(
                    question: question,
                    questionNumber: index + 1,
                    selectedOptionIndex: userAnswer,
                    showCorrectAnswer: true,
                    isResultView: true,
                    wasAnsweredCorrectly: userAnswer != -1 ? isCorrect : null,
                  ),
                );
              },
            ),
          ),

          // Action Buttons
          Container(
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
                  child: CustomButton(
                    text: 'Try Again',
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        app_routes.AppRoutes.takeQuiz,
                        arguments: {
                          'moduleId': moduleId,
                          'quizId': quizId,
                        },
                      );
                    },
                    variant: ButtonVariant.outlined,
                    textColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: Dimensions.md),
                Expanded(
                  child: CustomButton(
                    icon: Icons.home,
                    text: 'Dashboard',
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        app_routes.AppRoutes.home,
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.md,
        vertical: Dimensions.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyles.h3.copyWith(color: color),
          ),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
