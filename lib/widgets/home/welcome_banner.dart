import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';

class WelcomeBanner extends StatelessWidget {
  final String username;
  final String role;

  const WelcomeBanner({
    Key? key,
    required this.username,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyles.bodyLarge.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: Dimensions.xs),
          Text(
            username,
            style: TextStyles.h1.copyWith(
              color: AppColors.white,
            ),
          ),
          Text(
            role.toUpperCase(),
            style: TextStyles.caption.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
