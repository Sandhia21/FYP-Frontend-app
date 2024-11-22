import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/constants.dart';
import '../../../../providers/quiz_provider.dart';
import '../../../../widgets/common/app_bar.dart';
import '../../../../widgets/common/custom_button.dart';
import '../../../../widgets/quiz/quiz_card.dart';
import '../../../../data/models/quiz.dart';
import '../../../../widgets/common/error_widget.dart';
import '../../../../widgets/common/empty_state_view.dart';
import '../../../../services/routes.dart';
import '../create_quiz_screen.dart';
import '../../../../widgets/quiz/quiz_management_helper.dart';

class QuizManagementScreen extends StatefulWidget {
  final int moduleId;

  const QuizManagementScreen({
    super.key,
    required this.moduleId,
  });

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final quizProvider = context.read<QuizProvider>();
    await quizProvider.fetchQuizzes(widget.moduleId);
  }

  Future<void> _navigateToCreateQuiz({Quiz? quiz}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuizScreen(
          moduleId: widget.moduleId,
          quiz: quiz,
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadQuizzes();
    }
  }

  Future<void> _handleDeleteQuiz(Quiz quiz) async {
    await QuizManagementHelper.handleDeleteQuiz(
      context: context,
      quiz: quiz,
      onSuccess: () async {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz deleted successfully')),
          );
          await _loadQuizzes();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage Quizzes'),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizProvider.error != null) {
            return CustomErrorWidget(
              message: quizProvider.error!,
              onRetry: _loadQuizzes,
            );
          }

          if (quizProvider.quizzes.isEmpty) {
            return EmptyStateView(
              icon: Icons.quiz,
              title: 'No Quizzes Yet',
              message: 'Create your first quiz to get started',
              action: CustomButton(
                text: 'Create Quiz',
                onPressed: () => _navigateToCreateQuiz(),
                icon: Icons.add,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(Dimensions.md),
            itemCount: quizProvider.quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizProvider.quizzes[index];
              return QuizCard(
                quiz: quiz,
                isTeacher: true,
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.quizDetail,
                  arguments: {
                    'moduleId': widget.moduleId,
                    'quizId': quiz.id,
                    'isTeacher': true,
                  },
                ),
                onEdit: () => _navigateToCreateQuiz(quiz: quiz),
                onDelete: () => _handleDeleteQuiz(quiz),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateQuiz(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CardMetadata {
  final IconData icon;
  final String label;

  const CardMetadata({
    required this.icon,
    required this.label,
  });
}
