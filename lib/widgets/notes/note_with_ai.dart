import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../providers/note_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_button.dart';

class NoteWithAI extends StatefulWidget {
  final int moduleId;
  final String topic;
  final Function(String) onContentGenerated;

  const NoteWithAI({
    super.key,
    required this.moduleId,
    required this.topic,
    required this.onContentGenerated,
  });

  @override
  State<NoteWithAI> createState() => _NoteWithAIState();
}

class _NoteWithAIState extends State<NoteWithAI> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateContent();
  }

  Future<void> _generateContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await AIService.generateNotes(
        topic: widget.topic,
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          '/note-preview',
          arguments: {
            'moduleId': widget.moduleId,
            'topic': widget.topic,
            'content': content,
          },
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Generating Note', style: TextStyles.h2),
              const SizedBox(height: Dimensions.md),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyles.bodyMedium.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.lg),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Try Again',
                        onPressed: _generateContent,
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: Dimensions.md),
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const CircularProgressIndicator(),
                const SizedBox(height: Dimensions.lg),
                const Text(
                  'Generating note content with AI...',
                  style: TextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
