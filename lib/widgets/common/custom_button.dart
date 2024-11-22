import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../constants/button_variant.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Future<void> Function()? asyncOnPressed;
  final Color? textColor;
  final Color? borderColor;
  final bool isOutlined;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final IconData? icon;
  final Gradient? gradient;
  final ButtonVariant variant;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.asyncOnPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.isOutlined = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.icon,
    this.gradient,
    this.variant = ButtonVariant.filled,
  }) : super(key: key);

  bool get _isDisabled =>
      isDisabled || (onPressed == null && asyncOnPressed == null);

  void _handlePress() {
    if (isLoading || _isDisabled) return;

    if (asyncOnPressed != null) {
      asyncOnPressed!();
    } else if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: BoxConstraints(
        minWidth: 88.0,
        maxWidth: width ?? double.infinity,
      ),
      height: 48.0,
      child: isOutlined ? _buildOutlinedButton() : _buildElevatedButton(),
    );
  }

  Widget _buildElevatedButton() {
    if (variant == ButtonVariant.outlined) {
      return _buildOutlinedButton();
    }

    if (gradient != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: _isDisabled ? null : gradient,
          color: _isDisabled ? AppColors.grey.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
          boxShadow: _isDisabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (isLoading || _isDisabled) ? null : _handlePress,
            borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
            child: Center(child: _buildButtonContent()),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: (isLoading || _isDisabled) ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isDisabled
            ? AppColors.grey.withOpacity(0.3)
            : backgroundColor ?? AppColors.primary,
        foregroundColor:
            _isDisabled ? AppColors.grey : textColor ?? AppColors.white,
        elevation: _isDisabled ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: width != null ? Dimensions.md : Dimensions.lg,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: (isLoading || _isDisabled) ? null : _handlePress,
      style: OutlinedButton.styleFrom(
        foregroundColor:
            _isDisabled ? AppColors.grey : textColor ?? AppColors.primary,
        side: BorderSide(
          color: _isDisabled
              ? AppColors.grey.withOpacity(0.3)
              : borderColor ?? backgroundColor ?? AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: width != null ? Dimensions.md : Dimensions.lg,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 24.0,
        width: 24.0,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _isDisabled
                ? AppColors.grey
                : variant == ButtonVariant.outlined || isOutlined
                    ? textColor ?? AppColors.primary
                    : AppColors.white,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 24.0,
            color: _isDisabled
                ? AppColors.grey
                : variant == ButtonVariant.outlined || isOutlined
                    ? textColor ?? AppColors.primary
                    : AppColors.white,
          ),
          const SizedBox(width: 8.0),
        ],
        Text(
          text,
          style: TextStyle(
            color: _isDisabled
                ? AppColors.grey
                : variant == ButtonVariant.outlined || isOutlined
                    ? textColor ?? AppColors.primary
                    : AppColors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
