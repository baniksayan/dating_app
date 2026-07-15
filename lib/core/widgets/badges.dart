import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Colors;
import '../extensions/build_context_ext.dart';
import '../theme/app_design_system.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  const VerifiedBadge({super.key, this.size = 18.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          AppIcons.verified,
          color: const Color(0xFF4A90E2), // Classic verified blue
          size: size * 0.85,
        ),
      ),
    );
  }
}

class PremiumBadge extends StatelessWidget {
  final double size;
  const PremiumBadge({super.key, this.size = 18.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppGradients.gold,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          AppIcons.premium,
          color: context.colors.background,
          size: size * 0.6,
        ),
      ),
    );
  }
}
