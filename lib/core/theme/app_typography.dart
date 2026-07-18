import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required double letterSpacing,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontFamilyFallback: const ['sans-serif'],
    );
  }

  // Display Large - Used for screen branding, giant statements
  static TextStyle get displayLarge => _style(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.0,
      );

  // Display Medium - Used for main onboarding headers
  static TextStyle get displayMedium => _style(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      );

  // Headline - Used for major section headers or profile names
  static TextStyle get headline => _style(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.2,
      );

  // Title - Used for cards and secondary headers
  static TextStyle get title => _style(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.1,
      );

  // Body - Core copy, descriptions, details
  static TextStyle get body => _style(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.0,
      );

  // Caption - Secondary metadata, small indicators
  static TextStyle get caption => _style(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        letterSpacing: 0.1,
        color: AppColors.textSecondary,
      );

  // Button - Call-to-actions, action labels
  static TextStyle get button => _style(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0.2,
      );

  // Label - Small badge titles, input titles, tags
  static TextStyle get label => _style(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.1,
      );
}
