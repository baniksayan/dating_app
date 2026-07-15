import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppRadius {
  AppRadius._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double pill = 999.0;

  static BorderRadius get borderXs => BorderRadius.circular(xs);
  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderPill => BorderRadius.circular(pill);
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const SizedBox spaceXs = SizedBox(width: xs, height: xs);
  static const SizedBox spaceSm = SizedBox(width: sm, height: sm);
  static const SizedBox spaceMd = SizedBox(width: md, height: md);
  static const SizedBox spaceLg = SizedBox(width: lg, height: lg);
  static const SizedBox spaceXl = SizedBox(width: xl, height: xl);
  static const SizedBox spaceXxl = SizedBox(width: xxl, height: xxl);
}

class AppShadows {
  AppShadows._();
  
  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: AppColors.rawBlack.withOpacity(0.04),
          blurRadius: 8.0,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get premium => [
        BoxShadow(
          color: AppColors.rawBlack.withOpacity(0.25),
          blurRadius: 20.0,
          spreadRadius: -4.0,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.rawBlack.withOpacity(0.12),
          blurRadius: 8.0,
          spreadRadius: -2.0,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardFloating => [
        BoxShadow(
          color: AppColors.rawBlack.withOpacity(0.4),
          blurRadius: 30.0,
          spreadRadius: 2.0,
          offset: const Offset(0, 15),
        ),
      ];

  static List<Shadow> get textShadow => [
        Shadow(
          color: AppColors.rawBlack.withOpacity(0.6),
          blurRadius: 10.0,
          offset: const Offset(0, 2),
        ),
        Shadow(
          color: AppColors.rawBlack.withOpacity(0.3),
          blurRadius: 2.0,
          offset: const Offset(0, 1),
        ),
      ];
}

class AppIcons {
  AppIcons._();

  // Navigation Icons
  static const IconData swipe = CupertinoIcons.double_tilt_card;
  static const IconData explore = CupertinoIcons.compass;
  static const IconData likes = CupertinoIcons.heart;
  static const IconData chat = CupertinoIcons.bubble_left_bubble_right;
  static const IconData profile = CupertinoIcons.person;

  // Swipe Action Icons
  static const IconData rewind = CupertinoIcons.arrow_counterclockwise;
  static const IconData dislike = CupertinoIcons.xmark;
  static const IconData superlike = CupertinoIcons.star_fill;
  static const IconData like = CupertinoIcons.heart_fill;
  static const IconData boost = CupertinoIcons.bolt_fill;

  // Status & Utility Icons
  static const IconData verified = CupertinoIcons.checkmark_seal_fill;
  static const IconData premium = CupertinoIcons.square_stack_3d_up_fill;
  static const IconData location = CupertinoIcons.location_fill;
  static const IconData settings = CupertinoIcons.settings;
  static const IconData back = CupertinoIcons.left_chevron;
  static const IconData send = CupertinoIcons.paperplane_fill;
  static const IconData search = CupertinoIcons.search;
  static const IconData filter = CupertinoIcons.slider_horizontal_3;
  static const IconData close = CupertinoIcons.xmark_circle_fill;
}

class AppDurations {
  AppDurations._();
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration swipeFeedback = Duration(milliseconds: 200);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient luxury = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientEnd,
    ],
  );

  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientGoldStart,
      AppColors.gradientGoldEnd,
    ],
  );

  static const LinearGradient overlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x33000000),
      Color(0xCC000000),
      AppColors.rawBlack,
    ],
    stops: [0.0, 0.4, 0.8, 1.0],
  );
}

class AppBorders {
  AppBorders._();
  static Border get glass => Border.all(
        color: AppColors.glassBorder,
        width: 1.0,
      );

  static Border get subtle => Border.all(
        color: AppColors.divider,
        width: 1.0,
      );
}

class AppBlur {
  AppBlur._();
  static const double subtle = 8.0;
  static const double medium = 20.0;
  static const double heavy = 40.0;
}
