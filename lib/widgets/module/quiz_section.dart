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
                      color: AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.md),
              Expanded(
                child: quizProvider.quizzes.isEmpty
                    ? const Center(
                        child: Text(
                          'No quizzes available',
                          style: TextStyles.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: quizProvider.quizzes.length,
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.sm,
                          horizontal: Dimensions.xs,
                        ),
                        itemBuilder: (context, index) {
                          final quiz = quizProvider
                              .quizzes[quizProvider.quizzes.length - 1 - index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: Dimensions.md),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Dimensions.sm),
                                side: BorderSide(
                                  color: AppColors.grey.withOpacity(0.2),
                                ),
                              ),
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
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.md,
                                  vertical: Dimensions.sm,
                                ),
                                title: Text(
                                  quiz.title,
                                  style: TextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  'Duration: ${quiz.quizDuration} minutes',
                                  style: TextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(Dimensions.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(Dimensions.sm),
                                  ),
                                  child: const Icon(
                                    Icons.quiz_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                trailing: widget.isTeacher
                                    ? PopupMenuButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: AppColors.textSecondary,
                                        ),
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
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
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
