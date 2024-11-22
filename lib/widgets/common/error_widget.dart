import 'package:flutter/material.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CustomErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Oops!',
              style: TextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.md),
            Text(
              message,
              style: TextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.lg),
            CustomButton(
              text: 'Retry',
              onPressed: onRetry,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}
