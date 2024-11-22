import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../providers/note_provider.dart';
import '../../data/models/note.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_button.dart';
import 'note_with_ai.dart';
import '../../ui/screens/notes/note_detail_screen.dart';

class NoteCrudDialog extends StatefulWidget {
  final int moduleId;
  final Note? note;

  const NoteCrudDialog({
    super.key,
    required this.moduleId,
    this.note,
  });

  @override
  State<NoteCrudDialog> createState() => _NoteCrudDialogState();
}

class _NoteCrudDialogState extends State<NoteCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _topicController;
  late TextEditingController _contentController;
  bool _isLoading = false;
  bool _isAIMode = false;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _topicController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _generateNoteWithAI() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final noteProvider = context.read<NoteProvider>();

      // Show loading dialog with AI generation status
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NoteWithAI(
          moduleId: widget.moduleId,
          topic: _topicController.text.trim(),
          onContentGenerated: (content) async {
            // Create the note with AI-generated content
            await noteProvider.createNote(
              widget.moduleId,
              _topicController.text.trim(),
              content,
            );

            if (mounted) {
              Navigator.of(context).pop(); // Close AI dialog
              Navigator.of(context).pop(true); // Close create note dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Note created successfully with AI')),
              );
            }
          },
        ),
      );
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

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final noteProvider = context.read<NoteProvider>();

      if (isEditing) {
        await noteProvider.updateNote(
          widget.moduleId,
          widget.note!.id,
          _topicController.text.trim(),
          _contentController.text.trim(),
        );
      } else {
        if (_isAIMode) {
          await _generateNoteWithAI();
        } else {
          await noteProvider.createNote(
            widget.moduleId,
            _topicController.text.trim(),
            _contentController.text.trim(),
          );
        }
      }

      if (mounted) Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
      ),
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Note' : 'Create Note',
                  style: TextStyles.h2,
                ),
                const SizedBox(height: Dimensions.md),
                if (!isEditing) ...[
                  Text(
                    'Want to generate note content using AI? Toggle the switch below.',
                    style: TextStyles.bodyLarge
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: Dimensions.sm),
                  Row(
                    children: [
                      Text(
                        'Generate with AI',
                        style: TextStyles.bodyMedium,
                      ),
                      const Spacer(),
                      Switch(
                        value: _isAIMode,
                        onChanged: (value) => setState(() => _isAIMode = value),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.md),
                ],
                TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: 'Topic',
                    hintText: 'Enter note topic',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a topic';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: Dimensions.lg),
                if (!_isAIMode || isEditing)
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      hintText: 'Enter note content',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter content';
                      }
                      return null;
                    },
                    maxLines: 10,
                  ),
                const SizedBox(height: Dimensions.lg),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: Dimensions.md),
                    Expanded(
                      child: CustomButton(
                        text: _isAIMode && !isEditing ? 'Generate' : 'Save',
                        onPressed: _isAIMode && !isEditing
                            ? _generateNoteWithAI
                            : _saveNote,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
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
}
