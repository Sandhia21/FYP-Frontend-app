import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';

class TextStyles {
  // Markdown Headings with better hierarchy
  static const TextStyle h1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 26.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Body text with better readability
  static const TextStyle bodyLarge = TextStyle(
    fontSize: Dimensions.fontLg,
    color: AppColors.textPrimary,
    height: 1.6,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: Dimensions.fontMd,
    color: AppColors.textPrimary,
    height: 1.6,
    letterSpacing: 0.15,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: Dimensions.fontSm,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // Markdown specific styles
  static const TextStyle blockquote = TextStyle(
    fontSize: Dimensions.fontMd,
    color: AppColors.textSecondary,
    height: 1.6,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.15,
  );

  static const TextStyle code = TextStyle(
    fontSize: Dimensions.fontMd,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: 'monospace',
    letterSpacing: 0,
    backgroundColor: AppColors.surface,
  );

  static const TextStyle codeBlock = TextStyle(
    fontSize: Dimensions.fontSm,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: 'monospace',
    letterSpacing: 0,
  );

  // List text styles
  static const TextStyle listItem = TextStyle(
    fontSize: Dimensions.fontMd,
    color: AppColors.textPrimary,
    height: 1.6,
    letterSpacing: 0.15,
  );

  // Button text styles
  static const TextStyle buttonText = TextStyle(
    fontSize: Dimensions.fontMd,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static const TextStyle buttonTextSmall = TextStyle(
    fontSize: Dimensions.fontSm,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Input text
  static const TextStyle input = TextStyle(
    fontSize: Dimensions.fontMd,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: Dimensions.fontSm,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  // Link text
  static const TextStyle link = TextStyle(
    fontSize: Dimensions.fontMd,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  // Error text
  static const TextStyle error = TextStyle(
    fontSize: Dimensions.fontSm,
    color: AppColors.error,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // Caption text
  static const TextStyle caption = TextStyle(
    fontSize: Dimensions.fontXs,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0.1,
  );
}
