import 'package:flutter/painting.dart';

class AppColors {
  AppColors._();

  // Core Palette Hex Constants
  static const Color rawPrimary = Color(0xFF79A3C3);    // Soft Classic Blue
  static const Color rawDarkBrown = Color(0xFF3A2119);   // Deep Luxury Brown
  static const Color rawSoftBlue = Color(0xFFD2E2EC);    // Lighter, Airy Blue
  static const Color rawWarmBeige = Color(0xFFEBCDB7);   // Warm Golden Beige
  static const Color rawMutedBrown = Color(0xFF957662);  // Earthy Secondary Brown
  static const Color rawBlack = Color(0xFF000000);       // Pure Black
  static const Color rawWhite = Color(0xFFFFFFFF);       // Pure White

  // Semantic Design System Tokens (Dark Mode Preferred for Luxury)
  static const Color primary = rawPrimary;
  static const Color background = rawBlack;
  static const Color surface = Color(0xFF131110);        // Near black with warm dark brown undertones
  static const Color card = Color(0xFF1A1716);           // Elevated surface card with warm dark brown tint
  static const Color accent = rawWarmBeige;
  static const Color divider = Color(0xFF2C2522);        // Subtle divider using warm/dark brown mix
  static const Color textPrimary = rawWhite;
  static const Color textSecondary = rawMutedBrown;
  static const Color textTertiary = Color(0xFF6E5648);   // Deeper muted brown for captions
  
  // Status Colors
  static const Color error = Color(0xFFD9534F);          // Elegant Crimson
  static const Color success = Color(0xFF5CB85C);        // Premium Sage Green
  static const Color warning = Color(0xFFF0AD4E);        // Soft Amber

  // Overlay / Translucents (Cupertino / Apple Wallet style)
  static const Color overlay = Color(0x99000000);        // 60% Black
  static const Color glassBackground = Color(0x1F2C2522); // Glass effect overlay using warm dark brown base
  static const Color glassBorder = Color(0x33FFFFFF);     // Subtle white highlight for glass edges

  // Gradients (Apple Music / Raya style luxury)
  static const Color gradientStart = rawPrimary;
  static const Color gradientEnd = rawDarkBrown;

  // Secondary Luxury Gradient (Beige to Soft Blue)
  static const Color gradientGoldStart = rawWarmBeige;
  static const Color gradientGoldEnd = rawMutedBrown;

  // Swiping Colors
  static const Color swipeLike = Color(0xFF8BB582);      // Elegant green for Like
  static const Color swipeDislike = Color(0xFFC76F6F);   // Elegant red for Dislike
  static const Color swipeSuperLike = Color(0xFF7FA8D0); // Elegant blue for Superlike
}
