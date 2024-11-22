import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/constants.dart';
import '../../../../data/models/quiz.dart';
import '../../../../providers/quiz_provider.dart';
import '../../../../widgets/common/app_bar.dart';
import '../../../../widgets/common/error_widget.dart';
import '../create_quiz_screen.dart';

import '../../../../widgets/common/ai_banner.dart';

class QuizDetailScreen extends StatefulWidget {
  final int moduleId;
  final int quizId;
  final bool isTeacher;

  const QuizDetailScreen({
    super.key,
    required this.moduleId,
    required this.quizId,
    this.isTeacher = false,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool _isLoading = true;
  String? _error;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadQuizDetails();
  }

  Future<void> _loadQuizDetails() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      await quizProvider.fetchQuizDetails(widget.moduleId, widget.quizId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEdit(Quiz quiz) async {
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
      _loadQuizDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quiz Details',
        actions: widget.isTeacher
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    final quiz = context.read<QuizProvider>().selectedQuiz;
                    if (quiz != null) {
                      _handleEdit(quiz);
                    }
                  },
                  tooltip: 'Edit Quiz',
                ),
              ]
            : null,
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
            return CustomErrorWidget(
              message: _error!,
              onRetry: () => setState(() => _initFuture = _loadQuizDetails()),
            );
          }

          return Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              final quiz = quizProvider.selectedQuiz;
              if (quiz == null) {
                return CustomErrorWidget(
                  message: 'Quiz not found',
                  onRetry: () =>
                      setState(() => _initFuture = _loadQuizDetails()),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quiz Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Dimensions.lg),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            style: TextStyles.h3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (quiz.description.isNotEmpty) ...[
                            const SizedBox(height: Dimensions.sm),
                            Text(
                              quiz.description,
                              style: TextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: Dimensions.md),
                          Wrap(
                            spacing: Dimensions.sm,
                            runSpacing: Dimensions.sm,
                            children: [
                              _InfoChip(
                                icon: Icons.timer_outlined,
                                label: '${quiz.quizDuration} mins',
                              ),
                              _InfoChip(
                                icon: Icons.question_answer_outlined,
                                label:
                                    '${quiz.parsedQuestions.length} Questions',
                              ),
                              _InfoChip(
                                icon: Icons.repeat_outlined,
                                label: '${quiz.maxAttempts} Attempts',
                              ),
                              if (quiz.isAIGenerated)
                                const AIBanner(isCompact: true),
                            ],
                          ),
                          if (quiz.note?.isNotEmpty ?? false) ...[
                            const SizedBox(height: Dimensions.md),
                            Container(
                              padding: const EdgeInsets.all(Dimensions.sm),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.borderRadiusSm),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: Dimensions.sm),
                                  Expanded(
                                    child: Text(
                                      quiz.note!,
                                      style: TextStyles.bodySmall.copyWith(
                                        color: AppColors.warning,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Questions Section
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Questions',
                            style: TextStyles.h4.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Dimensions.md),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: quiz.parsedQuestions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: Dimensions.md),
                            itemBuilder: (context, index) {
                              final question = quiz.parsedQuestions[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.borderRadiusMd),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.all(Dimensions.md),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Question ${index + 1}',
                                            style:
                                                TextStyles.bodyMedium.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: Dimensions.xs),
                                          Text(
                                            question.question,
                                            style:
                                                TextStyles.bodyLarge.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...question.options
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final isCorrect =
                                          entry.value == question.correctAnswer;
                                      final optionLetter =
                                          String.fromCharCode(65 + entry.key);

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: widget.isTeacher && isCorrect
                                              ? const Color(0xFFE8F5E9)
                                              : Colors.white,
                                          border: Border(
                                            top: BorderSide(
                                              color: AppColors.inputBorder
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: Dimensions.md,
                                            vertical: Dimensions.sm,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '$optionLetter)',
                                                  style: TextStyles.bodyMedium
                                                      .copyWith(
                                                    color: widget.isTeacher &&
                                                            isCorrect
                                                        ? AppColors.success
                                                        : AppColors
                                                            .textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  entry.value,
                                                  style: TextStyles.bodyMedium
                                                      .copyWith(
                                                    color: widget.isTeacher &&
                                                            isCorrect
                                                        ? AppColors.success
                                                        : AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              if (isCorrect)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: Dimensions.sm),
                                                  child: const Icon(
                                                    Icons.check_circle_outline,
                                                    color: AppColors.success,
                                                    size: 20,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.md,
        vertical: Dimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: Dimensions.sm),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
