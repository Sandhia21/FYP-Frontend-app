import 'package:app/constants/button_variant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../providers/result_provider.dart';
import '../../services/routes.dart';
import '../common/loading_overlay.dart';
import '../common/custom_button.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../constants/dimensions.dart';
import '../../providers/quiz_provider.dart';
import '../../data/models/quiz.dart';

class ResultSection extends StatefulWidget {
  final int moduleId;
  final bool isTeacher;

  const ResultSection({
    super.key,
    required this.moduleId,
    this.isTeacher = false,
  });

  @override
  State<ResultSection> createState() => _ResultSectionState();
}

class _ResultSectionState extends State<ResultSection> {
  late QuizProvider _quizProvider;
  late ResultProvider _resultProvider;
  Quiz? _selectedQuiz;

  @override
  void initState() {
    super.initState();
    _quizProvider = Provider.of<QuizProvider>(context, listen: false);
    _resultProvider = Provider.of<ResultProvider>(context, listen: false);
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    await _quizProvider.fetchQuizzes(widget.moduleId);
  }

  Future<void> _loadQuizResults(int quizId) async {
    await _resultProvider.fetchResults(widget.moduleId, quizId);
    if (widget.isTeacher) {
      await _resultProvider.fetchLeaderboard(widget.moduleId, quizId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QuizProvider, ResultProvider>(
      builder: (context, quizProvider, resultProvider, child) {
        if (quizProvider.isLoading || resultProvider.isLoading) {
          return const LoadingOverlay(
            isLoading: true,
            child: SizedBox.expand(),
          );
        }

        if (_selectedQuiz == null) {
          return _buildQuizList(quizProvider.quizzes);
        }

        return Column(
          children: [
            _buildQuizHeader(),
            if (widget.isTeacher && resultProvider.leaderboard != null)
              _buildStatsCard(resultProvider.leaderboard!),
            Expanded(
              child: _buildQuizResultsList(resultProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuizList(List<Quiz> quizzes) {
    if (quizzes.isEmpty) {
      return const Center(
        child: Text('No quizzes available'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(Dimensions.md),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.md),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.sm),
                    side: BorderSide(
                      color: AppColors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() => _selectedQuiz = quiz);
                      _loadQuizResults(quiz.id);
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.md,
                      vertical: Dimensions.sm,
                    ),
                    title: Text(
                      quiz.title,
                      style: TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      'Duration: ${quiz.quizDuration} minutes',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(Dimensions.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.sm),
                      ),
                      child: const Icon(
                        Icons.quiz_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuizHeader() {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.md),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _selectedQuiz = null),
          ),
          Expanded(
            child: Text(
              _selectedQuiz?.title ?? '',
              style: TextStyles.h3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> leaderboard) {
    return Card(
      margin: const EdgeInsets.all(Dimensions.md),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Students',
              (leaderboard['total_students'] ?? 0).toString(),
              Icons.people,
            ),
            _buildStatItem(
              'Submitted',
              (leaderboard['submitted_count'] ?? 0).toString(),
              Icons.check_circle,
            ),
            _buildStatItem(
              'Pending',
              (leaderboard['pending_count'] ?? 0).toString(),
              Icons.pending,
            ),
            _buildStatItem(
              'Average',
              '${(leaderboard['average_score'] ?? 0.0).toStringAsFixed(1)}%',
              Icons.analytics,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResultsList(ResultProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final results = provider.results;

    if (results.isEmpty) {
      return const Center(
        child: Text('This Quiz is not Attempted Yet.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.md,
            vertical: Dimensions.sm,
          ),
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(Dimensions.sm),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getScoreColor(result.percentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.person_outline),
                ),
              ),
              title: Text(
                '${result.studentName ?? 'Unknown Student'} - ${result.percentage.toStringAsFixed(1)}%',
                style: TextStyles.bodyLarge.copyWith(
                  color: _getScoreColor(result.percentage),
                ),
              ),
              subtitle: Text(
                'Submitted: ${_formatDate(result.dateTaken)}',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: SizedBox(
                width: 100,
                child: CustomButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.quizResult,
                      arguments: {
                        'moduleId': widget.moduleId,
                        'quizId': _selectedQuiz?.id ?? -1,
                        'resultId': result.id ?? -1,
                        'isTeacher': widget.isTeacher,
                      },
                    );
                  },
                  text: 'View',
                  variant: ButtonVariant.outlined,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(ResultProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error loading results',
            style: TextStyles.h3.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: Dimensions.sm),
          Text(
            provider.error ?? 'Unknown error occurred',
            style: TextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.md),
          CustomButton(
            text: 'Retry',
            onPressed: () => _loadQuizResults(_selectedQuiz?.id ?? -1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: Dimensions.iconMd),
        const SizedBox(height: Dimensions.xs),
        Text(
          value,
          style: TextStyles.h3.copyWith(color: AppColors.primary),
        ),
        Text(
          label,
          style: TextStyles.caption,
        ),
      ],
    );
  }

  void _showRecommendations(String title, String recommendations) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 800,
          ),
          padding: const EdgeInsets.all(Dimensions.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyles.h3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.grey,
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: Dimensions.sm),
              Expanded(
                child: SingleChildScrollView(
                  child: MarkdownBody(
                    data: recommendations,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyles.bodyMedium,
                      h1: TextStyles.h1,
                      h2: TextStyles.h2,
                      h3: TextStyles.h3,
                      listBullet: TextStyles.bodyMedium,
                      blockquote: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      code: TextStyles.bodyMedium.copyWith(
                        fontFamily: 'monospace',
                        backgroundColor: AppColors.lightGrey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(dynamic percentage) {
    final double score = percentage is int ? percentage.toDouble() : percentage;

    if (score >= 80) {
      return AppColors.success;
    } else if (score >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
