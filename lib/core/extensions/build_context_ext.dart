import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_design_system.dart';

extension BuildContextExt on BuildContext {
  // Theme lookups
  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Semantic Design System Shortcuts
  AppColorsClass get colors => const AppColorsClass();
  AppTypographyClass get typography => const AppTypographyClass();
  AppSpacingClass get spacing => const AppSpacingClass();
  AppRadiusClass get radius => const AppRadiusClass();

  // Media Query dimensions
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  double get statusBarHeight => mediaQuery.padding.top;
  double get bottomBarHeight => mediaQuery.padding.bottom;

  // Responsive breakpoints
  bool get isSmallPhone => screenWidth < 375;
  bool get isTablet => screenWidth >= 768;
}

// Wrapper classes to mimic namespaces in Dart extensions
class AppColorsClass {
  const AppColorsClass();
  Color get primary => AppColors.primary;
  Color get background => AppColors.background;
  Color get surface => AppColors.surface;
  Color get card => AppColors.card;
  Color get accent => AppColors.accent;
  Color get divider => AppColors.divider;
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textTertiary => AppColors.textTertiary;
  Color get error => AppColors.error;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get overlay => AppColors.overlay;
  Color get glassBackground => AppColors.glassBackground;
  Color get glassBorder => AppColors.glassBorder;
  Color get gradientStart => AppColors.gradientStart;
  Color get gradientEnd => AppColors.gradientEnd;
  Color get swipeLike => AppColors.swipeLike;
  Color get swipeDislike => AppColors.swipeDislike;
  Color get swipeSuperLike => AppColors.swipeSuperLike;
}

class AppTypographyClass {
  const AppTypographyClass();
  TextStyle get displayLarge => AppTypography.displayLarge;
  TextStyle get displayMedium => AppTypography.displayMedium;
  TextStyle get headline => AppTypography.headline;
  TextStyle get title => AppTypography.title;
  TextStyle get body => AppTypography.body;
  TextStyle get caption => AppTypography.caption;
  TextStyle get button => AppTypography.button;
  TextStyle get label => AppTypography.label;
}

class AppSpacingClass {
  const AppSpacingClass();
  double get xs => AppSpacing.xs;
  double get sm => AppSpacing.sm;
  double get md => AppSpacing.md;
  double get lg => AppSpacing.lg;
  double get xl => AppSpacing.xl;
  double get xxl => AppSpacing.xxl;

  SizedBox get spaceXs => AppSpacing.spaceXs;
  SizedBox get spaceSm => AppSpacing.spaceSm;
  SizedBox get spaceMd => AppSpacing.spaceMd;
  SizedBox get spaceLg => AppSpacing.spaceLg;
  SizedBox get spaceXl => AppSpacing.spaceXl;
  SizedBox get spaceXxl => AppSpacing.spaceXxl;
}

class AppRadiusClass {
  const AppRadiusClass();
  double get xs => AppRadius.xs;
  double get sm => AppRadius.sm;
  double get md => AppRadius.md;
  double get lg => AppRadius.lg;
  double get xl => AppRadius.xl;
  double get xxl => AppRadius.xxl;
  double get pill => AppRadius.pill;

  BorderRadius get borderXs => AppRadius.borderXs;
  BorderRadius get borderSm => AppRadius.borderSm;
  BorderRadius get borderMd => AppRadius.borderMd;
  BorderRadius get borderLg => AppRadius.borderLg;
  BorderRadius get borderXl => AppRadius.borderXl;
  BorderRadius get borderXxl => AppRadius.borderXxl;
  BorderRadius get borderPill => AppRadius.borderPill;
}
