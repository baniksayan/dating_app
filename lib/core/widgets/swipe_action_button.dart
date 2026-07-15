import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../extensions/build_context_ext.dart';
import '../theme/app_design_system.dart';

class SwipeActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  const SwipeActionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.size,
    this.backgroundColor,
    this.onTap,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? context.colors.card;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onTap != null
            ? () {
                HapticFeedback.mediumImpact();
                onTap!();
              }
            : null,
        behavior: HitTestBehavior.opaque, // Ensures touch responsiveness
        child: Padding(
          // Enforces 44x44 minimum touch target padding per Apple HIG
          padding: const EdgeInsets.all(4.0),
          child: AnimatedOpacity(
            opacity: onTap == null ? 0.3 : 1.0,
            duration: AppDurations.quick,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bg,
                border: AppBorders.glass,
                boxShadow: AppShadows.subtle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: iconColor,
                size: size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
