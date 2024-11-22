import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../data/models/parsed_questions.dart';

class ResultCard extends StatelessWidget {
  final ParsedQuestion question;
  final int selectedOptionIndex;
  final bool isCorrect;
  final bool isTeacherView;
  final int questionNumber;

  const ResultCard({
    Key? key,
    required this.question,
    required this.selectedOptionIndex,
    required this.isCorrect,
    this.isTeacherView = false,
    required this.questionNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
        side: BorderSide(
          color: AppColors.inputBorder.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Text with number
            Wrap(
              children: [
                Text(
                  '$questionNumber. ${question.question}',
                  style: TextStyles.h4,
                ),
              ],
            ),
            const SizedBox(height: Dimensions.md),

            // Only show "Your answer" for student view
            if (!isTeacherView && selectedOptionIndex >= 0) ...[
              Wrap(
                children: [
                  Text(
                    'Your answer: ',
                    style: TextStyles.bodyMedium,
                  ),
                  Text(
                    '${_indexToLetter(selectedOptionIndex)}) ${question.options[selectedOptionIndex]}',
                    style: TextStyles.bodyMedium.copyWith(
                      color: isCorrect ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.md),
            ],

            // All Options
            Text(
              'All Options:',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: Dimensions.sm),
            ...List.generate(
              question.options.length,
              (index) => Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.md,
                  bottom: Dimensions.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_indexToLetter(index)}) ',
                      style: TextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: TextStyles.bodyMedium.copyWith(
                          color: _getOptionColor(index),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getOptionColor(int index) {
    if (index == question.correctOptionIndex) {
      return AppColors.success;
    }
    if (!isTeacherView && index == selectedOptionIndex && !isCorrect) {
      return AppColors.error;
    }
    return AppColors.textPrimary;
  }

  String _indexToLetter(int index) {
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }
}
