import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:app/constants/constants.dart';
import '../../../providers/note_provider.dart';
import '../../../data/models/note.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/notes/note_crud_dialog.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/notes/note_with_ai.dart';

class NoteDetailScreen extends StatefulWidget {
  final int moduleId;
  final int? noteId;
  final bool isPreview;
  final String? topic;
  final bool isTeacher;

  const NoteDetailScreen({
    super.key,
    required this.moduleId,
    this.noteId,
    this.isPreview = false,
    this.topic,
    this.isTeacher = false,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool _isLoading = false;
  String? _error;
  bool _mounted = true;
  String? _generatedContent;

  @override
  void initState() {
    super.initState();
    if (widget.isPreview) {
      _generatePreview();
    } else if (widget.noteId != null) {
      _loadNote();
    }
  }

  Future<void> _generatePreview() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoteWithAI(
        moduleId: widget.moduleId,
        topic: widget.topic!,
        onContentGenerated: (content) {
          setState(() => _generatedContent = content);
        },
      ),
    );
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.getNote(widget.moduleId, widget.noteId!);
    } catch (e) {
      if (_mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteNote(BuildContext context, Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && _mounted) {
      setState(() => _isLoading = true);
      try {
        final noteProvider = Provider.of<NoteProvider>(context, listen: false);
        await noteProvider.deleteNote(widget.moduleId, note.id);
        if (_mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (_mounted) {
          setState(() => _error = e.toString());
        }
      } finally {
        if (_mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.isPreview ? 'Preview Generated Note' : 'Note',
      ),
      body: widget.isPreview ? _buildPreview() : _buildNote(),
    );
  }

  Widget _buildPreview() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!, style: TextStyles.error));
    }

    if (_generatedContent == null) {
      return const Center(child: Text('Generating content...'));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.topic!, style: TextStyles.h2),
                const SizedBox(height: Dimensions.lg),
                MarkdownBody(
                  data: _generatedContent!,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyles.bodyMedium.copyWith(height: 1.5),
                    h1: TextStyles.h1,
                    h2: TextStyles.h2,
                    h3: TextStyles.h3,
                    h4: TextStyles.h4,
                    h5: TextStyles.h5,
                    h6: TextStyles.h6,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(Dimensions.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Regenerate',
                    onPressed: _generatePreview,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: Dimensions.md),
                Expanded(
                  child: CustomButton(
                    text: 'Save Note',
                    onPressed: () async {
                      final noteProvider = context.read<NoteProvider>();
                      await noteProvider.createNote(
                        widget.moduleId,
                        widget.topic!,
                        _generatedContent!,
                      );
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
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
          ),
        ),
      ],
    );
  }

  Widget _buildNote() {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_error != null) {
          return Center(
            child: Text(_error!, style: TextStyles.error),
          );
        }

        final note = noteProvider.selectedNote;
        if (note == null) {
          return const Center(child: Text('Note not found'));
        }

        return SafeArea(
          child: Column(
            children: [
              // Note Content
              Expanded(
                child: LoadingOverlay(
                  isLoading: _isLoading,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.lg,
                      vertical: Dimensions.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.isTeacher)
                          Text(
                            'Notes Based on ${note.title}',
                            style: TextStyles.h2,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        const SizedBox(height: Dimensions.lg),
                        MarkdownBody(
                          data: note.content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyles.bodyMedium.copyWith(height: 1.5),
                            h1: TextStyles.h1,
                            h2: TextStyles.h2,
                            h3: TextStyles.h3,
                            h4: TextStyles.h4,
                            h5: TextStyles.h5,
                            h6: TextStyles.h6,
                          ),
                        ),
                        const SizedBox(height: Dimensions.lg),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.md,
                  vertical: Dimensions.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Edit Note',
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => NoteCrudDialog(
                              moduleId: widget.moduleId,
                              note: note,
                            ),
                          ),
                          backgroundColor: AppColors.secondary,
                          icon: Icons.edit,
                        ),
                      ),
                      const SizedBox(width: Dimensions.md),
                      Expanded(
                        child: CustomButton(
                          text: 'Delete Note',
                          onPressed: () => _deleteNote(context, note),
                          backgroundColor: AppColors.error,
                          icon: Icons.delete,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
