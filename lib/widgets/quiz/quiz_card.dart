import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../data/models/quiz.dart';
import '../common/ai_banner.dart';
import '../common/custom_button.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final bool isTeacher;
  final VoidCallback onPressed;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.isTeacher,
    required this.onPressed,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: Dimensions.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(Dimensions.borderRadiusLg),
                    ),
                    child: const Icon(Icons.quiz_outlined,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: Dimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(quiz.title, style: TextStyles.h4),
                        if (quiz.description.isNotEmpty) ...[
                          const SizedBox(height: Dimensions.xs),
                          Text(
                            quiz.description,
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (quiz.isAIGenerated) ...[
                    const SizedBox(width: Dimensions.sm),
                    const AIBanner(isCompact: true),
                  ],
                ],
              ),
              const SizedBox(height: Dimensions.md),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '${quiz.quizDuration} mins',
                  ),
                  const SizedBox(width: Dimensions.md),
                  _InfoChip(
                    icon: Icons.question_answer_outlined,
                    label: '${quiz.parsedQuestions.length} Q',
                  ),
                  const SizedBox(width: Dimensions.md),
                  _InfoChip(
                    icon: Icons.repeat_outlined,
                    label: '${quiz.maxAttempts} attempts',
                  ),
                  const Spacer(),
                  if (isTeacher) ...[
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onEdit,
                        tooltip: 'Edit Quiz',
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: onDelete,
                        tooltip: 'Delete Quiz',
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
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
        horizontal: Dimensions.sm,
        vertical: Dimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSm),
        border: Border.all(
          color: AppColors.inputBorder.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: Dimensions.xs),
          Text(
            label,
            style: TextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
