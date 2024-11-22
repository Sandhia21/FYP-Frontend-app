import 'package:flutter/material.dart';
import '../../../constants/constants.dart';
import '../../../data/models/parsed_questions.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/quiz/quiz_question_view.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/quiz/question_form_dialog.dart';

class QuizPreviewScreen extends StatefulWidget {
  final String title;
  final String description;
  final String duration;
  final List<ParsedQuestion> questions;
  final Function(String, String, String, List<ParsedQuestion>)? onApprove;

  const QuizPreviewScreen({
    super.key,
    required this.title,
    required this.description,
    required this.duration,
    required this.questions,
    this.onApprove,
  });

  @override
  State<QuizPreviewScreen> createState() => _QuizPreviewScreenState();
}

class _QuizPreviewScreenState extends State<QuizPreviewScreen> {
  int _currentQuestionIndex = 0;
  final bool _isLoading = false;
  late final List<ParsedQuestion> _editableQuestions;
  final Map<int, int?> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _editableQuestions = List.from(widget.questions);
    for (var i = 0; i < _editableQuestions.length; i++) {
      _selectedOptions[i] = null;
    }
  }

  void _updateQuestion(ParsedQuestion updatedQuestion) {
    setState(() {
      _editableQuestions[_currentQuestionIndex] = updatedQuestion;
    });
  }

  void _deleteQuestion(int index) {
    setState(() {
      _editableQuestions.removeAt(index);
      // Update selected options map
      for (var i = index; i < _editableQuestions.length; i++) {
        _selectedOptions[i] = _selectedOptions[i + 1];
      }
      _selectedOptions.remove(_editableQuestions.length);

      // Adjust current index if necessary
      if (_currentQuestionIndex >= _editableQuestions.length) {
        _currentQuestionIndex = _editableQuestions.length - 1;
      }
    });
  }

  void _handleOptionSelected(int index) {
    setState(() {
      _selectedOptions[_currentQuestionIndex] = index;
    });
  }

  Future<void> _showEditDialog(ParsedQuestion question) async {
    final result = await showDialog<ParsedQuestion>(
      context: context,
      builder: (context) => QuestionFormDialog(
        initialQuestion: question,
        isEditing: true,
        onSave: (edited) => _updateQuestion(edited),
      ),
    );

    if (result != null) {
      _updateQuestion(result);
    }
  }

  Widget _buildQuestionPreviewSection() {
    if (_editableQuestions.isEmpty) {
      return const Center(
        child: Text('No questions available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Preview Questions', style: TextStyles.h3),
            Text(
              'Question ${_currentQuestionIndex + 1}/${_editableQuestions.length}',
              style: TextStyles.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: Dimensions.md),
        QuizQuestionView(
          question: _editableQuestions[_currentQuestionIndex],
          questionNumber: _currentQuestionIndex + 1,
          selectedOptionIndex: _selectedOptions[_currentQuestionIndex],
          onAnswerSelected: _handleOptionSelected,
          showCorrectAnswer: true,
          isPreview: true,
          isEditable: true,
          onQuestionUpdated: _updateQuestion,
          onEdit: () =>
              _showEditDialog(_editableQuestions[_currentQuestionIndex]),
          onDelete: () => _deleteQuestion(_currentQuestionIndex),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Preview Generated Quiz',
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _editableQuestions.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: Dimensions.md),
                    Text(
                      'No questions available',
                      style: TextStyles.bodyLarge,
                    ),
                    SizedBox(height: Dimensions.sm),
                    Text(
                      'Try generating new questions',
                      style: TextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(Dimensions.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quiz Details Section
                          Text('Quiz Details', style: TextStyles.h3),
                          const SizedBox(height: Dimensions.md),
                          _buildQuizDetailsCard(),
                          const SizedBox(height: Dimensions.xl),
                          _buildQuestionPreviewSection(),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomNavigation(),
                ],
              ),
      ),
    );
  }

  Widget _buildQuizDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(Dimensions.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.description, style: TextStyles.bodyMedium),
          const SizedBox(height: Dimensions.sm),
          Text(
            'Duration: ${widget.duration} minutes',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'Total Questions: ${_editableQuestions.length}',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    if (_editableQuestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.lg),
        child: CustomButton(
          text: 'Go Back',
          onPressed: () => Navigator.pop(context),
          width: double.infinity,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(Dimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            text: 'Approve & Create',
            onPressed: _editableQuestions.isEmpty
                ? null
                : () {
                    if (widget.onApprove != null) {
                      widget.onApprove!(
                        widget.title,
                        widget.description,
                        widget.duration,
                        _editableQuestions,
                      );
                    }
                    Navigator.pop(context, true);
                  },
            width: double.infinity,
            backgroundColor: AppColors.success,
          ),
          const SizedBox(height: Dimensions.md),
          if (_editableQuestions.isNotEmpty)
            Row(
              children: [
                if (_currentQuestionIndex > 0) ...[
                  Expanded(
                    child: CustomButton(
                      text: 'Previous',
                      onPressed: () => setState(() => _currentQuestionIndex--),
                      icon: Icons.arrow_back,
                      isOutlined: true,
                      textColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: Dimensions.md),
                ],
                Expanded(
                  child: CustomButton(
                    text: _currentQuestionIndex < _editableQuestions.length - 1
                        ? 'Next'
                        : 'Discard',
                    onPressed: () {
                      if (_currentQuestionIndex <
                          _editableQuestions.length - 1) {
                        setState(() => _currentQuestionIndex++);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Quiz creation cancelled'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                      }
                    },
                    icon: _currentQuestionIndex < _editableQuestions.length - 1
                        ? Icons.arrow_forward
                        : Icons.close,
                    backgroundColor:
                        _currentQuestionIndex < _editableQuestions.length - 1
                            ? null
                            : AppColors.error,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
