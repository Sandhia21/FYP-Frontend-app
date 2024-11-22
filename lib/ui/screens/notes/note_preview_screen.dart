import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../providers/note_provider.dart';
import '../../../services/ai_service.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/common/custom_button.dart';

class NotePreviewScreen extends StatefulWidget {
  final int moduleId;
  final String topic;
  final String initialContent;
  final bool isTeacher;

  const NotePreviewScreen({
    super.key,
    required this.moduleId,
    required this.topic,
    required this.initialContent,
    this.isTeacher = false,
  });

  @override
  State<NotePreviewScreen> createState() => _NotePreviewScreenState();
}

class _NotePreviewScreenState extends State<NotePreviewScreen> {
  late TextEditingController _contentController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _regenerateContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await AIService.generateNotes(
        topic: widget.topic,
      );
      setState(() => _contentController.text = content);
    } catch (e) {
      setState(() => _error = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveContent() async {
    setState(() => _isLoading = true);

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.createNote(
        widget.moduleId,
        widget.topic,
        _contentController.text,
        fromAI: true,
      );

      if (mounted) {
        // Pop the preview screen
        Navigator.pop(context, true);
        // Pop the note creation dialog
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note created successfully')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!)),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // title: 'Preview Generated Note',
        title: widget.topic,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Edit Content', style: TextStyles.h3),
                    const SizedBox(height: Dimensions.md),
                    TextFormField(
                      controller: _contentController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Note content in markdown format',
                      ),
                    ),
                    const SizedBox(height: Dimensions.xl),
                    Text('Preview', style: TextStyles.h3),
                    const SizedBox(height: Dimensions.md),
                    Container(
                      padding: const EdgeInsets.all(Dimensions.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.inputBorder),
                        borderRadius:
                            BorderRadius.circular(Dimensions.borderRadiusLg),
                      ),
                      child: MarkdownBody(
                        data: _contentController.text,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyles.bodyMedium,
                          h1: TextStyles.h1,
                          h2: TextStyles.h2,
                          h3: TextStyles.h3,
                          h4: TextStyles.h4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
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
                    text: 'Approve',
                    onPressed: _approveContent,
                    width: double.infinity,
                    backgroundColor: AppColors.success,
                  ),
                  const SizedBox(height: Dimensions.md),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Regenerate',
                          onPressed: _regenerateContent,
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: Dimensions.md),
                      Expanded(
                        child: CustomButton(
                          text: 'Discard',
                          onPressed: () => Navigator.pop(context),
                          backgroundColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
