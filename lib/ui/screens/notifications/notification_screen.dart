import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/enrollment_provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../data/models/enrollment.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnrollmentProvider>().loadStudentEnrollmentRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        actions: const [], // Empty list to override default notification icon
      ),
      body: Consumer<EnrollmentProvider>(
        builder: (context, provider, child) {
          return LoadingOverlay(
            isLoading: provider.isLoading,
            child: _buildContent(provider),
          );
        },
      ),
    );
  }

  Widget _buildContent(EnrollmentProvider provider) {
    if (provider.error != null) {
      return CustomErrorWidget(
        message: provider.error!,
        onRetry: () => provider.loadStudentEnrollmentRequests(),
      );
    }

    if (provider.studentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: AppColors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: Dimensions.md),
            Text(
              'No notifications',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: Dimensions.xs),
            Text(
              'You don\'t have any notifications at the moment',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.lg),
            CustomButton(
              text: 'Refresh',
              onPressed: () => provider.loadStudentEnrollmentRequests(),
              icon: Icons.refresh,
              isOutlined: true,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadStudentEnrollmentRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.md),
        itemCount: provider.studentRequests.length,
        itemBuilder: (context, index) {
          final request = provider.studentRequests[index];
          return _buildNotificationCard(request);
        },
      ),
    );
  }

  Widget _buildNotificationCard(StudentEnrollmentRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
          border: Border.all(
            color: _getStatusColor(request.status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Dimensions.borderRadiusSm),
                      image: DecorationImage(
                        image: NetworkImage(
                            "http://192.168.100.6:8000${request.courseImage}"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.courseName,
                          style: TextStyles.bodyMedium,
                        ),
                        const SizedBox(height: Dimensions.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.sm,
                            vertical: Dimensions.xs / 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(request.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                Dimensions.borderRadiusSm),
                          ),
                          child: Text(
                            _getStatusMessage(request.status),
                            style: TextStyles.caption.copyWith(
                              color: _getStatusColor(request.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (request.courseDescription.isNotEmpty) ...[
                const SizedBox(height: Dimensions.sm),
                Text(
                  request.courseDescription,
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Enrollment Request Pending';
      case 'approved':
        return 'Enrollment Approved';
      case 'rejected':
        return 'Enrollment Rejected';
      default:
        return 'Unknown Status';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
