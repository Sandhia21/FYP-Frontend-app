import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../providers/result_provider.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/common/custom_button.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../data/models/result.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../constants/button_variant.dart';

class QuizResultScreen extends StatefulWidget {
  final int moduleId;
  final int quizId;
  final int resultId;
  final bool isTeacher;

  const QuizResultScreen({
    super.key,
    required this.moduleId,
    required this.quizId,
    required this.resultId,
    required this.isTeacher,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  @override
  void initState() {
    super.initState();
    _loadResultDetails();
  }

  Future<void> _loadResultDetails() async {
    if (!mounted) return;
    final resultProvider = Provider.of<ResultProvider>(context, listen: false);
    await resultProvider.fetchResultDetails(
      widget.moduleId,
      widget.quizId,
      widget.resultId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quiz Result',
        showBackButton: true,
        centerTitle: true,
        hideProfileIcon: true,
      ),
      body: Consumer<ResultProvider>(
        builder: (context, resultProvider, child) {
          if (resultProvider.isLoading) {
            return const LoadingOverlay(
              isLoading: true,
              child: SizedBox.expand(),
            );
          }

          if (resultProvider.error != null) {
            return _buildError(resultProvider.error!);
          }

          final result = resultProvider.currentResult;
          if (result == null) {
            return const Center(
              child: Text('Result not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoreCard(result),
                const SizedBox(height: Dimensions.md),
                _buildQuizContent(result),
                if (result.aiRecommendations != null) ...[
                  const SizedBox(height: Dimensions.md),
                  _buildRecommendations(result.aiRecommendations!),
                ],
                const SizedBox(height: Dimensions.lg),
                if (!widget.isTeacher) _buildNavigationButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(Result result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isTeacher && result.studentName != null) ...[
              Text(
                'Student: ${result.studentName}',
                style: TextStyles.h3,
              ),
              const SizedBox(height: Dimensions.sm),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: TextStyles.bodyLarge,
                    ),
                    Text(
                      '${result.percentage}%',
                      style: TextStyles.h2.copyWith(
                        color: _getScoreColor(result.percentage),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(Dimensions.md),
                  decoration: BoxDecoration(
                    color: _getScoreColor(result.percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.md),
                  ),
                  child: Icon(
                    _getScoreIcon(result.percentage),
                    color: _getScoreColor(result.percentage),
                    size: 48,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.sm),
            Text(
              'Submitted: ${_formatDate(result.dateTaken)}',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(Result result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Answers',
              style: TextStyles.h3,
            ),
            const SizedBox(height: Dimensions.md),
            MarkdownBody(
              data: result.quizContent,
              styleSheet: MarkdownStyleSheet(
                p: TextStyles.bodyMedium,
                h1: TextStyles.h2,
                h2: TextStyles.h3,
                h3: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                listBullet: TextStyles.bodyMedium,
                blockquote: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(String recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Recommendations',
              style: TextStyles.h3,
            ),
            const SizedBox(height: Dimensions.md),
            MarkdownBody(
              data: recommendations,
              styleSheet: MarkdownStyleSheet(
                p: TextStyles.bodyMedium,
                h1: TextStyles.h2,
                h2: TextStyles.h3,
                h3: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                listBullet: TextStyles.bodyMedium,
                blockquote: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error loading result',
            style: TextStyles.h3.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: Dimensions.sm),
          Text(
            error,
            style: TextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.md),
          CustomButton(
            text: 'Retry',
            onPressed: _loadResultDetails,
          ),
        ],
      ),
    );
  }

  IconData _getScoreIcon(double percentage) {
    if (percentage >= 80) {
      return Icons.emoji_events;
    } else if (percentage >= 60) {
      return Icons.thumb_up;
    } else {
      return Icons.refresh;
    }
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) {
      return AppColors.success;
    } else if (percentage >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Try Again',
            variant: ButtonVariant.outlined,
            onPressed: () {
              // Pop twice to go back to quiz screen
              // Navigator.of(context).pop();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
        const SizedBox(width: Dimensions.md),
        Expanded(
          child: CustomButton(
            text: 'Home',
            variant: ButtonVariant.filled,
            onPressed: () {
              // Pop until home screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      ],
    );
  }
}
