import 'dart:ui';
import 'package:flutter/widgets.dart';
import '../extensions/build_context_ext.dart';
import '../theme/app_design_system.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurAmount;
  final Color? backgroundColor;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.blurAmount = AppBlur.medium,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final activeBorderRadius = borderRadius ?? context.radius.borderLg;
    final activeBgColor = backgroundColor ?? context.colors.glassBackground;
    final activeBorder = border ?? AppBorders.glass;

    return ClipRRect(
      borderRadius: activeBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: activeBgColor,
            borderRadius: activeBorderRadius,
            border: activeBorder,
          ),
          child: child,
        ),
      ),
    );
  }
}
