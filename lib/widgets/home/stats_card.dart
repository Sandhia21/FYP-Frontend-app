import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient? gradient; // Add gradient parameter

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.md),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppColors.white : null,
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: gradient != null ? AppColors.white : AppColors.primary,
          ),
          const SizedBox(height: Dimensions.sm),
          Text(
            value,
            style: TextStyles.h2.copyWith(
              color: gradient != null ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyles.caption.copyWith(
              color: gradient != null
                  ? AppColors.white.withOpacity(0.8)
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
