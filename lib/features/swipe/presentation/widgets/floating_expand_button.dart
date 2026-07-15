import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Colors, Icons;

class FloatingExpandButton extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const FloatingExpandButton({
    super.key,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<FloatingExpandButton> createState() => _FloatingExpandButtonState();
}

class _FloatingExpandButtonState extends State<FloatingExpandButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Press scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.isExpanded ? 'Collapse profile details' : 'Expand profile details',
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          HapticFeedback.mediumImpact(); // Firm iOS-like feedback tick
          widget.onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            width: 52,
            height: 52, // Large touch target (iOS HIG compliant accessibility area)
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  widget.isExpanded 
                      ? Icons.arrow_circle_down_rounded 
                      : Icons.arrow_circle_up_rounded,
                  key: ValueKey<bool>(widget.isExpanded),
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20, // Visually small (size of bio text)
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
