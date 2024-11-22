import 'package:flutter/material.dart';
import '../../constants/constants.dart';

class AIBanner extends StatelessWidget {
  final bool isCompact;

  const AIBanner({
    Key? key,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? Dimensions.xs : Dimensions.sm,
        vertical: isCompact ? Dimensions.xs - 4 : Dimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: isCompact ? 14 : 16,
            color: AppColors.primary,
          ),
          SizedBox(width: isCompact ? 2 : 4),
          Text(
            'AI Generated',
            style: isCompact ? TextStyles.caption : TextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
