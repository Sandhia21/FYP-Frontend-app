import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../constants/button_variant.dart';
import '../../../data/models/parsed_questions.dart';
import '../../../data/models/quiz.dart';
import '../../../widgets/common/app_bar.dart';
import 'quiz_preview_screen.dart';
import '../../../services/ai_service.dart';
import '../../../widgets/quiz/question_form_dialog.dart';

class CreateQuizScreen extends StatefulWidget {
  final int moduleId;
  final Quiz? quiz;

  const CreateQuizScreen({
    super.key,
    required this.moduleId,
    this.quiz,
  });

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _maxAttemptsController = TextEditingController(text: '1');
  final _numberOfQuestionsController = TextEditingController(text: '5');
  final List<ParsedQuestion> _questions = [];
  bool _isLoading = false;

  bool _useAI = false;

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _titleController.text = widget.quiz!.title;
      _descriptionController.text = widget.quiz!.description;
      _durationController.text = widget.quiz!.quizDuration.toString();
      _maxAttemptsController.text = widget.quiz!.maxAttempts.toString();
      _questions.addAll(widget.quiz!.parsedQuestions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Create Quiz',
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Create Quiz using AI'),
                        Switch(
                          value: _useAI,
                          onChanged: (value) => setState(() => _useAI = value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_useAI)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomTextField(
                        controller: _numberOfQuestionsController,
                        labelText: 'Number of Questions',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          final number = int.tryParse(value!);
                          if (number == null || number < 1) {
                            return 'Enter a valid number';
                          }
                          if (number > 20) {
                            return 'Maximum 20 questions allowed';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _titleController,
                          labelText: _useAI ? 'Topic' : 'Quiz Title',
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _descriptionController,
                          labelText: 'Description',
                          maxLines: 3,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _durationController,
                                labelText: 'Duration (minutes)',
                                keyboardType: TextInputType.number,
                                validator: (value) =>
                                    value?.isEmpty ?? true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _maxAttemptsController,
                                labelText: 'Maximum Attempts',
                                keyboardType: TextInputType.number,
                                validator: (value) =>
                                    value?.isEmpty ?? true ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_useAI)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Questions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _questions.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) =>
                                _buildQuestionItem(index),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Add Question',
                            onPressed: _showQuestionForm,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        variant: ButtonVariant.outlined,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Create',
                        onPressed: _handleCreate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionItem(int index) {
    final question = _questions[index];
    return ListTile(
      title: Text(question.question),
      subtitle: Text('Correct Answer: ${question.correctAnswer}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showQuestionForm(question),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteQuestion(index),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_useAI) {
        final quizContent = await AIService.generateQuiz(
          topic: _titleController.text,
          numberOfQuestions: int.parse(_numberOfQuestionsController.text),
          difficulty: 'medium',
        );

        final questions = _parseAIQuizContent(quizContent);

        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPreviewScreen(
                title: _titleController.text,
                description: _descriptionController.text,
                duration: _durationController.text,
                questions: questions,
                onApprove: (title, description, duration, questions) async {
                  await context.read<QuizProvider>().createQuiz(
                        moduleId: widget.moduleId,
                        title: title,
                        description: description,
                        duration: int.parse(duration),
                        maxAttempts: int.parse(_maxAttemptsController.text),
                        questions: questions,
                      );
                },
              ),
            ),
          );
          if (result == true) Navigator.pop(context);
        }
      } else {
        if (_questions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add at least one question')),
          );
          return;
        }

        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPreviewScreen(
                title: _titleController.text,
                description: _descriptionController.text,
                duration: _durationController.text,
                questions: _questions,
                onApprove: (title, description, duration, questions) async {
                  await context.read<QuizProvider>().createQuiz(
                        moduleId: widget.moduleId,
                        title: title,
                        description: description,
                        duration: int.parse(duration),
                        maxAttempts: int.parse(_maxAttemptsController.text),
                        questions: questions,
                      );
                },
              ),
            ),
          );
          if (result == true) Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ParsedQuestion> _parseAIQuizContent(String content) {
    final questions = <ParsedQuestion>[];
    final questionBlocks = content.split('\n\n');

    for (var block in questionBlocks) {
      if (block.trim().isEmpty) continue;

      final lines = block.split('\n');
      if (lines.length < 6) continue; // Question + 4 options + correct answer

      final questionText = lines[0].replaceAll(RegExp(r'^\d+\.\s*'), '');
      final options = lines.sublist(1, 5).map((line) {
        return line.replaceAll(RegExp(r'^[A-D]\)\s*'), '');
      }).toList();

      final correctAnswerLine = lines[5];
      final correctAnswer = correctAnswerLine.contains('Correct Answer:')
          ? correctAnswerLine.split(':')[1].trim()
          : 'A';
      final correctIndex = 'ABCD'.indexOf(correctAnswer);

      if (correctIndex != -1) {
        questions.add(ParsedQuestion(
          question: questionText,
          options: options,
          correctOptionIndex: correctIndex,
        ));
      }
    }

    return questions;
  }

  void _showQuestionForm([ParsedQuestion? question]) {
    showDialog(
      context: context,
      builder: (context) => QuestionFormDialog(
        initialQuestion: question,
        onSave: (newQuestion) {
          setState(() {
            if (question != null) {
              // Edit existing question
              final index = _questions.indexOf(question);
              _questions[index] = newQuestion;
            } else {
              // Add new question
              _questions.add(newQuestion);
            }
          });
        },
      ),
    );
  }

  void _deleteQuestion(int index) {
    setState(() => _questions.removeAt(index));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _maxAttemptsController.dispose();
    _numberOfQuestionsController.dispose();
    super.dispose();
  }
}
