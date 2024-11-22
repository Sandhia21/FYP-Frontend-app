import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/result_provider.dart';
import '../../data/models/result.dart';
import '../common/loading_overlay.dart';
import '../common/custom_button.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ResultSection extends StatefulWidget {
  final int moduleId;
  final int quizId;
  final bool isTeacher;

  const ResultSection({
    super.key,
    required this.moduleId,
    required this.quizId,
    this.isTeacher = false,
  });

  @override
  State<ResultSection> createState() => _ResultSectionState();
}

class _ResultSectionState extends State<ResultSection> {
  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    if (!mounted) return;
    final resultProvider = Provider.of<ResultProvider>(context, listen: false);
    await resultProvider.fetchResults(widget.moduleId, widget.quizId);

    if (widget.isTeacher) {
      await resultProvider.fetchLeaderboard(widget.moduleId, widget.quizId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResultProvider>(
      builder: (context, resultProvider, child) {
        if (resultProvider.isLoading) {
          return const LoadingOverlay(
            isLoading: true,
            child: SizedBox.expand(),
          );
        }

        if (resultProvider.error != null) {
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
                  resultProvider.error!,
                  style: TextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.md),
                CustomButton(
                  text: 'Retry',
                  onPressed: _loadResults,
                ),
              ],
            ),
          );
        }

        if (widget.isTeacher && resultProvider.leaderboard != null) {
          return _buildLeaderboard(resultProvider.leaderboard!);
        }

        return _buildStudentResults(resultProvider.results);
      },
    );
  }

  Widget _buildLeaderboard(Map<String, dynamic> leaderboard) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Results: ${leaderboard['quiz_title']}',
            style: TextStyles.h2,
          ),
          const SizedBox(height: Dimensions.md),
          _buildStatisticsCard(leaderboard),
          const SizedBox(height: Dimensions.md),
          Expanded(
            child: ListView.builder(
              itemCount: leaderboard['submissions'].length,
              itemBuilder: (context, index) {
                final submission = leaderboard['submissions'][index];
                return Card(
                  margin: const EdgeInsets.only(bottom: Dimensions.sm),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '${index + 1}',
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      submission['student_name'],
                      style: TextStyles.bodyLarge,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score: ${submission['percentage']}%',
                          style: TextStyles.bodySmall.copyWith(
                            color: _getScoreColor(submission['percentage']),
                          ),
                        ),
                        Text(
                          'Submitted: ${_formatDate(DateTime.parse(submission['submitted_at']))}',
                          style: TextStyles.bodySmall,
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      color: AppColors.primary,
                      onPressed: () => _showRecommendations(
                        submission['student_name'],
                        submission['ai_recommendations'] ??
                            'No recommendations available',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> leaderboard) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Students',
              leaderboard['total_students'].toString(),
              Icons.people,
            ),
            _buildStatItem(
              'Submitted',
              leaderboard['submitted_count'].toString(),
              Icons.check_circle,
            ),
            _buildStatItem(
              'Pending',
              leaderboard['pending_count'].toString(),
              Icons.pending,
            ),
            _buildStatItem(
              'Average',
              '${leaderboard['average_score'].toStringAsFixed(1)}%',
              Icons.analytics,
            ),
          ],
        ),
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

  Widget _buildStudentResults(List<Result> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz,
              size: Dimensions.iconLg,
              color: AppColors.grey,
            ),
            const SizedBox(height: Dimensions.md),
            Text(
              'No results available',
              style: TextStyles.h3,
            ),
            const SizedBox(height: Dimensions.sm),
            Text(
              'Complete a quiz to see your results here',
              style: TextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.all(Dimensions.md),
      itemBuilder: (context, index) {
        final result = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: Dimensions.sm),
          child: ListTile(
            leading: Icon(
              Icons.assignment,
              color: _getScoreColor(result.percentage),
              size: Dimensions.iconMd,
            ),
            title: Text(
              'Score: ${result.percentage}%',
              style: TextStyles.bodyLarge.copyWith(
                color: _getScoreColor(result.percentage),
              ),
            ),
            subtitle: Text(
              'Submitted: ${_formatDate(result.dateTaken)}',
              style: TextStyles.bodySmall,
            ),
            trailing: CustomButton(
              text: 'View Feedback',
              onPressed: () => _showRecommendations(
                'Your Results',
                result.aiRecommendations ?? 'No recommendations available',
              ),
            ),
          ),
        );
      },
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
}
