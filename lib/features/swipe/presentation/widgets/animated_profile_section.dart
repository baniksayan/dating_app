import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../../../core/theme/app_design_system.dart';

class AnimatedProfileSection extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayStep;

  const AnimatedProfileSection({
    super.key,
    required this.child,
    required this.index,
    this.delayStep = const Duration(milliseconds: 80), // Low delay step for snappy iOS feel
  });

  @override
  State<AnimatedProfileSection> createState() => _AnimatedProfileSectionState();
}

class _AnimatedProfileSectionState extends State<AnimatedProfileSection> {
  bool _isAnimating = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Delay start of animation based on item index for staggering effect
    _timer = Timer(widget.delayStep * widget.index, () {
      if (mounted) {
        setState(() {
          _isAnimating = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isAnimating ? 1.0 : 0.0,
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _isAnimating ? Offset.zero : const Offset(0.0, 0.15),
        duration: AppDurations.medium,
        curve: Curves.easeOutBack, // Custom spring curves
        child: widget.child,
      ),
    );
  }
}
