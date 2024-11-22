import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../data/models/parsed_questions.dart';
import '../common/custom_text_field.dart';
import '../common/custom_button.dart';

class QuestionFormDialog extends StatefulWidget {
  final ParsedQuestion? initialQuestion;
  final Function(ParsedQuestion) onSave;
  final bool isEditing;
  final int? questionNumber;

  const QuestionFormDialog({
    super.key,
    this.initialQuestion,
    required this.onSave,
    this.isEditing = false,
    this.questionNumber,
  });

  @override
  State<QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<QuestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final List<TextEditingController> _optionControllers;
  late int _correctOptionIndex;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _questionController = TextEditingController(
      text: widget.initialQuestion?.question ?? '',
    );
    _optionControllers = List.generate(
      4,
      (index) => TextEditingController(
        text: (widget.initialQuestion?.options.length ?? 0) > index
            ? widget.initialQuestion!.options[index]
            : '',
      ),
    );
    _correctOptionIndex = widget.initialQuestion?.correctOptionIndex ?? 0;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final question = ParsedQuestion(
      question: _questionController.text.trim(),
      options: _optionControllers
          .map((controller) => controller.text.trim())
          .toList(),
      correctOptionIndex: _correctOptionIndex,
    );

    widget.onSave(question);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEditing ? 'Edit Question' : 'Add Question',
        style: TextStyles.h3,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          onChanged: () => setState(() => _hasChanges = true),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _questionController,
                labelText: 'Question',
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Question is required' : null,
              ),
              const SizedBox(height: Dimensions.md),
              Text('Options', style: TextStyles.h4),
              const SizedBox(height: Dimensions.sm),
              ...List.generate(4, (index) => _buildOptionField(index)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _hasChanges ? _handleSave : null,
          child: Text(widget.isEditing ? 'Save Changes' : 'Add Question'),
        ),
      ],
    );
  }

  Widget _buildOptionField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.sm),
      child: Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: _correctOptionIndex,
            onChanged: (value) {
              setState(() {
                _correctOptionIndex = value!;
                _hasChanges = true;
              });
            },
            activeColor: AppColors.success,
          ),
          Expanded(
            child: CustomTextField(
              controller: _optionControllers[index],
              labelText: 'Option ${String.fromCharCode(65 + index)}',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Option is required' : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
