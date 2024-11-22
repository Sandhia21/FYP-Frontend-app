import 'package:flutter/material.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../constants/colors.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: Dimensions.md),
          Text(
            title,
            style: TextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.sm),
          Text(
            message,
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: Dimensions.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
