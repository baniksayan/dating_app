import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Colors;
import '../extensions/build_context_ext.dart';
import '../theme/app_design_system.dart';
import 'glass_card.dart';

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

class InteractiveBadge extends StatefulWidget {
  final Widget child;
  final String tooltipText;
  final IconData tooltipIcon;

  const InteractiveBadge({
    super.key,
    required this.child,
    required this.tooltipText,
    required this.tooltipIcon,
  });

  @override
  State<InteractiveBadge> createState() => _InteractiveBadgeState();
}

class _InteractiveBadgeState extends State<InteractiveBadge> {
  bool _showTooltip = false;

  void _toggleTooltip() {
    HapticFeedback.selectionClick();
    setState(() {
      _showTooltip = !_showTooltip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (event) {
        if (_showTooltip) {
          setState(() {
            _showTooltip = false;
          });
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: _toggleTooltip,
            behavior: HitTestBehavior.opaque,
            child: widget.child,
          ),
          
          // Tooltip Popover (animated scale/opacity)
          Positioned(
            bottom: 28,
            child: AnimatedScale(
              scale: _showTooltip ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: _showTooltip ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: IgnorePointer(
                  ignoring: !_showTooltip,
                  child: _buildTooltipContent(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipContent(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Rotated square forms popover arrow pointing down
        Positioned(
          bottom: -4,
          child: Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xE6000000), // Match tooltip bg
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
                ),
              ),
            ),
          ),
        ),

        // Popover glass card body
        GlassCard(
          blurAmount: AppBlur.medium,
          borderRadius: BorderRadius.circular(10),
          backgroundColor: const Color(0xE6000000), // iOS Liquid dark popover
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.tooltipIcon,
                color: const Color(0xFFEBCDB7), // Brand Warm Beige for elegant highlight
                size: 11,
              ),
              const SizedBox(width: 5),
              Text(
                widget.tooltipText,
                style: context.typography.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
