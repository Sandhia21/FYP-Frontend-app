import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../data/models/parsed_questions.dart';

class QuizQuestionView extends StatelessWidget {
  final ParsedQuestion question;
  final int questionNumber;
  final int? selectedOptionIndex;
  final Function(int)? onAnswerSelected;
  final bool showCorrectAnswer;
  final bool isPreview;
  final bool isTeacherView;
  final bool isEditable;
  final Function(ParsedQuestion)? onQuestionUpdated;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isCorrect;
  final bool isResultView;
  final bool? wasAnsweredCorrectly;

  const QuizQuestionView({
    super.key,
    required this.question,
    required this.questionNumber,
    this.selectedOptionIndex,
    this.onAnswerSelected,
    this.showCorrectAnswer = false,
    this.isPreview = false,
    this.isTeacherView = false,
    this.isEditable = false,
    this.onQuestionUpdated,
    this.onEdit,
    this.onDelete,
    this.isCorrect = false,
    this.isResultView = false,
    this.wasAnsweredCorrectly,
  });

  Future<void> _showEditDialog(BuildContext context) async {
    final result = await showDialog<ParsedQuestion>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Question'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: question.question),
                decoration: const InputDecoration(labelText: 'Question'),
                maxLines: 2,
              ),
              const SizedBox(height: Dimensions.md),
              ...List.generate(
                question.options.length,
                (index) => Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: question.correctOptionIndex,
                      onChanged: (value) {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: question.options[index],
                        ),
                        decoration: InputDecoration(
                          labelText:
                              'Option ${String.fromCharCode(65 + index)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedQuestion = ParsedQuestion(
                question: question.question,
                options: question.options,
                correctOptionIndex: question.correctOptionIndex,
              );
              Navigator.pop(context, updatedQuestion);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && onQuestionUpdated != null) {
      onQuestionUpdated!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Question ${questionNumber}'),
            trailing: isEditable
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: onDelete,
                      ),
                    ],
                  )
                : isResultView && wasAnsweredCorrectly != null
                    ? Icon(
                        wasAnsweredCorrectly!
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: wasAnsweredCorrectly!
                            ? AppColors.success
                            : AppColors.error,
                      )
                    : null,
          ),
          if (isResultView && selectedOptionIndex == -1)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.md,
                vertical: Dimensions.sm,
              ),
              color: AppColors.warning.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: Dimensions.sm),
                  Text(
                    'Not answered',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.question, style: TextStyles.bodyLarge),
                const SizedBox(height: Dimensions.md),
                ...List.generate(
                  question.options.length,
                  (index) => _buildOptionTile(index),
                ),
                if (isResultView && wasAnsweredCorrectly == false)
                  Padding(
                    padding: const EdgeInsets.only(top: Dimensions.md),
                    child: Text(
                      'Correct Answer: ${String.fromCharCode(65 + question.correctOptionIndex)}) ${question.options[question.correctOptionIndex]}',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(int index) {
    if (index >= question.options.length) return const SizedBox.shrink();

    final isSelected = selectedOptionIndex == index;
    final isCorrect = (showCorrectAnswer || isResultView) &&
        index == question.correctOptionIndex;
    final isWrong =
        (showCorrectAnswer || isResultView) && isSelected && !isCorrect;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.sm),
      child: InkWell(
        onTap: (!isResultView && onAnswerSelected != null)
            ? () => onAnswerSelected!(index)
            : null,
        child: Container(
          padding: const EdgeInsets.all(Dimensions.md),
          decoration: BoxDecoration(
            color: _getBackgroundColor(isSelected, isCorrect, isWrong),
            borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
            border: Border.all(
              color: _getBorderColor(isSelected, isCorrect, isWrong),
              width: isSelected || isCorrect ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                '${String.fromCharCode(65 + index)})',
                style: _getOptionTextStyle(isSelected, isCorrect),
              ),
              const SizedBox(width: Dimensions.md),
              Expanded(
                child: Text(
                  question.options[index],
                  style: _getOptionTextStyle(isSelected, isCorrect),
                ),
              ),
              if (showCorrectAnswer || isResultView) ...[
                const SizedBox(width: Dimensions.sm),
                Icon(
                  isCorrect
                      ? Icons.check_circle
                      : (isWrong ? Icons.cancel : null),
                  color: isCorrect
                      ? AppColors.success
                      : (isWrong ? AppColors.error : null),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _getOptionTextStyle(bool isSelected, bool isCorrect) {
    return TextStyles.bodyMedium.copyWith(
      color:
          isSelected || isCorrect ? AppColors.primary : AppColors.textPrimary,
      fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
    );
  }

  Color _getBackgroundColor(bool isSelected, bool isCorrect, bool isWrong) {
    if (isCorrect) return AppColors.success.withOpacity(0.1);
    if (isWrong) return AppColors.error.withOpacity(0.1);
    if (isSelected) return AppColors.primary.withOpacity(0.1);
    return Colors.transparent;
  }

  Color _getBorderColor(bool isSelected, bool isCorrect, bool isWrong) {
    if (isCorrect) return AppColors.success;
    if (isWrong) return AppColors.error;
    if (isSelected) return AppColors.primary;
    return AppColors.inputBorder;
  }
}
