import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/glass_card.dart';

class SwipeTutorialOverlay extends StatefulWidget {
  final GlobalKey cardDeckKey;
  final GlobalKey actionRowKey;
  final VoidCallback onFinish;

  const SwipeTutorialOverlay({
    super.key,
    required this.cardDeckKey,
    required this.actionRowKey,
    required this.onFinish,
  });

  @override
  State<SwipeTutorialOverlay> createState() => _SwipeTutorialOverlayState();
}

class _SwipeTutorialOverlayState extends State<SwipeTutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 1; // 1 to 4

  // Controllers for tutorial micro-animations
  late AnimationController _gestureController;
  late Animation<Offset> _handSlideAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Hand gesture slide animation (left/right/up swipe movements)
    _gestureController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _handSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0.0),
      end: const Offset(0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: _gestureController,
      curve: Curves.easeInOutSine,
    ));

    // 2. Pulse circle animation (for tap indications)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _pulseScaleAnimation = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    _setupAnimationForStep(1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _gestureController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _setupAnimationForStep(int step) {
    _gestureController.stop();
    _pulseController.stop();

    if (step == 1) {
      // Swipe left-right slide
      _handSlideAnimation = Tween<Offset>(
        begin: const Offset(-0.5, 0.0),
        end: const Offset(0.5, 0.0),
      ).animate(CurvedAnimation(
        parent: _gestureController,
        curve: Curves.easeInOutSine,
      ));
      _gestureController.repeat(reverse: true);
    } else if (step == 2) {
      // Pulse animation around buttons
      _pulseController.repeat();
    } else if (step == 3) {
      // Photo tapping: flash pulse on left and right alternate
      _pulseController.repeat();
    } else if (step == 4) {
      // Swipe details up
      _handSlideAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.4),
        end: const Offset(0.0, -0.4),
      ).animate(CurvedAnimation(
        parent: _gestureController,
        curve: Curves.easeOutQuad,
      ));
      _gestureController.repeat();
    }
  }

  Rect? _getTargetRect() {
    final GlobalKey key;
    if (_currentStep == 1 || _currentStep == 3 || _currentStep == 4) {
      key = widget.cardDeckKey;
    } else {
      key = widget.actionRowKey;
    }

    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    
    // Add custom sizing adjustments for details sheet/top tap areas if needed
    if (_currentStep == 3) {
      // Highlight the top photo indicators / tapping band of the card
      return Rect.fromLTWH(position.dx, position.dy, size.width, 100);
    } else if (_currentStep == 4) {
      // Highlight details drag handle / bottom details area
      return Rect.fromLTWH(position.dx, position.dy + size.height - 120, size.width, 120);
    }

    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _setupAnimationForStep(_currentStep);
    } else {
      widget.onFinish();
    }
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _setupAnimationForStep(_currentStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Rect? targetRect = _getTargetRect();

    return Stack(
      children: [
        // 1. Dimmed Spotlight cutout backdrop
        Positioned.fill(
          child: CustomPaint(
            painter: SpotlightPainter(
              spotlightRect: targetRect,
              borderRadius: _currentStep == 2 ? 32.0 : 20.0,
            ),
          ),
        ),

        // 2. Gesture Overlay Indicators (Cinematic Touch)
        if (targetRect != null) _buildGestureIndicators(targetRect),

        // 3. Floating Copy Instructions Card
        Positioned(
          left: 24,
          right: 24,
          // Shift instruction card depending on the spotlight location to avoid overlap
          bottom: (_currentStep == 2 || _currentStep == 4)
              ? context.screenHeight * 0.38
              : context.screenHeight * 0.12,
          child: _buildInstructionCard(context),
        ),
      ],
    );
  }

  Widget _buildGestureIndicators(Rect rect) {
    if (_currentStep == 1) {
      // Horizontal swipe hand
      return AnimatedBuilder(
        animation: _handSlideAnimation,
        builder: (context, child) {
          final Offset offset = _handSlideAnimation.value;
          return Positioned(
            left: rect.center.dx + (rect.width * offset.dx) - 24,
            top: rect.center.dy - 24,
            child: const Icon(
              CupertinoIcons.hand_draw_fill,
              color: Colors.white,
              size: 48,
              shadows: [
                Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(2, 2)),
              ],
            ),
          );
        },
      );
    } else if (_currentStep == 2) {
      // Pulsing button rings
      return AnimatedBuilder(
        animation: _pulseScaleAnimation,
        builder: (context, child) {
          final scale = _pulseScaleAnimation.value;
          final opacity = (1.5 - scale).clamp(0.0, 1.0);
          return Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                // Focus ring on the center Like and Nope buttons
                if (index != 1 && index != 3) return const SizedBox(width: 44);
                return Container(
                  width: 64 * scale,
                  height: 64 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.accent.withValues(alpha: opacity),
                      width: 2.0,
                    ),
                  ),
                );
              }),
            ),
          );
        },
      );
    } else if (_currentStep == 3) {
      // Photo Tapping pulses (alternating left/right taps)
      return AnimatedBuilder(
        animation: _pulseScaleAnimation,
        builder: (context, child) {
          final scale = _pulseScaleAnimation.value;
          final opacity = (1.5 - scale).clamp(0.0, 1.0);
          final bool tapRight = _pulseController.value > 0.5;

          return Positioned(
            left: tapRight ? rect.right - 80 : rect.left + 20,
            top: rect.center.dy - 30,
            child: Container(
              width: 60 * scale,
              height: 60 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withValues(alpha: opacity * 0.15),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: opacity),
                  width: 2.0,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                tapRight ? CupertinoIcons.hand_point_right_fill : CupertinoIcons.hand_point_left_fill,
                color: Colors.white.withValues(alpha: opacity),
                size: 24,
              ),
            ),
          );
        },
      );
    } else {
      // Swipe details sheet up hand
      return AnimatedBuilder(
        animation: _handSlideAnimation,
        builder: (context, child) {
          final Offset offset = _handSlideAnimation.value;
          return Positioned(
            left: rect.center.dx - 24,
            top: rect.center.dy + (rect.height * offset.dy) - 24,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.chevron_up,
                  color: Colors.white70,
                  size: 20,
                ),
                Icon(
                  CupertinoIcons.hand_draw_fill,
                  color: Colors.white,
                  size: 48,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(2, 2)),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildInstructionCard(BuildContext context) {
    final titles = [
      'Find Matches',
      'Action Buttons',
      'Photo Browsing',
      'Discover Details',
    ];

    final instructions = [
      'Swipe right to Like, left to Pass, or up to Super Like. Smooth physics are fully enabled.',
      'Tap standard controls if you prefer: Rewind, Pass, Super Like, Like, or Profile Boost.',
      'Tap the left or right edge of a photo to browse through additional images. Each photo reveals new compatibility attributes!',
      'Swipe up on the profile details card to read their bio, education, lifestyle choices, and relationship intentions.',
    ];

    return GlassCard(
      blurAmount: AppBlur.medium,
      borderRadius: BorderRadius.circular(20),
      backgroundColor: const Color(0xE31A1716), // Sheer card
      border: Border.all(color: context.colors.divider),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Counter & Skip button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x2AFFFFFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  '$_currentStep of 4',
                  style: context.typography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: widget.onFinish,
                child: Text(
                  'Skip tutorial',
                  style: context.typography.caption.copyWith(
                    color: context.colors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            titles[_currentStep - 1],
            style: context.typography.title.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Body text
          Text(
            instructions[_currentStep - 1],
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Action Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 1)
                GestureDetector(
                  onTap: _prevStep,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: context.radius.borderPill,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Back',
                      style: context.typography.button.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              
              GestureDetector(
                onTap: _nextStep,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.luxury,
                    borderRadius: context.radius.borderPill,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _currentStep == 4 ? 'Start discovering' : 'Next',
                    style: context.typography.button.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SpotlightPainter extends CustomPainter {
  final Rect? spotlightRect;
  final double borderRadius;

  SpotlightPainter({
    required this.spotlightRect,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (spotlightRect == null) return;

    // Dim background color (85% black)
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.85);

    // Main screen area rect
    final screenPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Pad rect slightly for visual comfort
    final rect = spotlightRect!;
    final paddedRect = Rect.fromLTRB(
      rect.left - 6,
      rect.top - 6,
      rect.right + 6,
      rect.bottom + 6,
    );

    // Rounded cutout path
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(paddedRect, Radius.circular(borderRadius)));

    // Combine difference
    final finalPath = Path.combine(PathOperation.difference, screenPath, cutoutPath);
    canvas.drawPath(finalPath, backgroundPaint);

    // Accent border around cutout (Golden/Beige highlight)
    final borderPaint = Paint()
      ..color = const Color(0xFFEBCDB7).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(paddedRect, Radius.circular(borderRadius)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.spotlightRect != spotlightRect || oldDelegate.borderRadius != borderRadius;
  }
}
