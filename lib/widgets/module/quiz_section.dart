import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../providers/quiz_provider.dart';
import '../common/loading_overlay.dart';

import '../common/custom_button.dart';
import '../../data/models/quiz.dart';
import '../../services/routes.dart';
import '../../ui/screens/quiz/create_quiz_screen.dart';

// TODO: This widget currently focuses on teacher functionality.
// Student-specific features will be implemented in a future update.
class QuizSection extends StatefulWidget {
  final int moduleId;
  final bool isTeacher;

  const QuizSection({
    super.key,
    required this.moduleId,
    this.isTeacher = false,
  });

  @override
  State<QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<QuizSection> {
  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.fetchQuizzes(widget.moduleId);
  }

  void _handleAddQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateQuizScreen(moduleId: widget.moduleId),
      ),
    );
  }

  Future<void> _handleDeleteQuiz(Quiz quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text('Are you sure you want to delete "${quiz.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final quizProvider = Provider.of<QuizProvider>(context, listen: false);
        await quizProvider.deleteQuiz(
          widget.moduleId,
          quiz.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isLoading) {
          return const LoadingOverlay(
            isLoading: true,
            child: SizedBox.expand(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(Dimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quizzes (${quizProvider.quizzes.length})',
                    style: TextStyles.h3,
                  ),
                  if (widget.isTeacher)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _handleAddQuiz,
                      tooltip: 'Create Quiz',
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.md),
              Expanded(
                child: quizProvider.quizzes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: Dimensions.md),
                            if (widget.isTeacher)
                              CustomButton(
                                text: 'Create First Quiz',
                                onPressed: _handleAddQuiz,
                                isOutlined: true,
                              )
                            else
                              const Text(
                                'Quizzes will appear here once your instructor creates them',
                                style: TextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: quizProvider.quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = quizProvider
                              .quizzes[quizProvider.quizzes.length - 1 - index];
                          return Card(
                            margin:
                                const EdgeInsets.only(bottom: Dimensions.sm),
                            child: ListTile(
                              onTap: () => Navigator.pushNamed(
                                context,
                                widget.isTeacher
                                    ? AppRoutes.quizDetail
                                    : AppRoutes.takeQuiz,
                                arguments: {
                                  'moduleId': widget.moduleId,
                                  'quizId': quiz.id,
                                  'isTeacher': widget.isTeacher,
                                },
                              ),
                              title:
                                  Text(quiz.title, style: TextStyles.bodyLarge),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duration: ${quiz.quizDuration} minutes',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    quiz.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: widget.isTeacher
                                  ? PopupMenuButton(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            _handleAddQuiz();
                                            break;
                                          case 'delete':
                                            _handleDeleteQuiz(quiz);
                                            break;
                                        }
                                      },
                                    )
                                  : const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
