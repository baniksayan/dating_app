import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_design_system.dart';

class AgeConfirmationDialog extends StatelessWidget {
  const AgeConfirmationDialog({super.key, required this.age});

  final int age;

  static Future<bool?> show(BuildContext context, {required int age}) {
    return showGeneralDialog<bool>(
      context: context,
      barrierLabel: 'Confirm Your Age',
      barrierDismissible: true,
      barrierColor: const Color(0xCC000000), // Deep 80% backdrop scrim
      transitionDuration: AppDurations.medium,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AgeConfirmationDialog(age: age);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppBlur.medium * animation.value,
              sigmaY: AppBlur.medium * animation.value,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  void _handleEditDate(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(false);
  }

  void _handleConfirm(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => _handleEditDate(context),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap:
                () {}, // Prevent taps inside the card from closing the dialog
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1817),
                  borderRadius: const BorderRadius.all(Radius.circular(28)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 40.0,
                      spreadRadius: 2.0,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildShieldBadge(),
                    const SizedBox(height: 20),
                    const Text(
                      'Confirm Your Age',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.rawWhite,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          decoration: TextDecoration.none,
                        ),
                        children: [
                          const TextSpan(text: 'Are you '),
                          TextSpan(
                            text: '$age',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const TextSpan(text: ' years old?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please make sure your date of birth is accurate as it will be displayed on your profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9E9E9E),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _EditDateButton(
                            onTap: () => _handleEditDate(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ConfirmButton(
                            age: age,
                            onTap: () => _handleConfirm(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShieldBadge() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF252220),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/svg_icons/circular-line-with-word-age-in-the-center-svgrepo-com.svg',
          width: 38,
          height: 38,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _EditDateButton extends StatelessWidget {
  const _EditDateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        child: const Text(
          'Edit Date',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.rawWhite,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.age, required this.onTap});

  final int age;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          "Yes, I'm $age",
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.rawBlack,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

/// Tactile press-scale wrapper for springy button interactions.
class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  double _scale = 1.0;

  void _setPressed(bool pressed) {
    setState(() => _scale = pressed ? 0.96 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: AppDurations.quick,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
