import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/helpers/formatter_helper.dart';
import 'profile_transition_container.dart';

enum SwipeDirection { left, right, up }

class SwipeCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;
  final ValueNotifier<SwipeDirection?>? triggerSwipeNotifier;
  final ValueNotifier<Offset>? dragOffsetNotifier; // reports live drag to parent
  final bool isTopCard;

  const SwipeCard({
    super.key,
    required this.user,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
    this.triggerSwipeNotifier,
    this.dragOffsetNotifier,
    this.isTopCard = false,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _translationAnim;
  late Animation<double> _rotationAnim;

  double _offsetX = 0.0;
  double _offsetY = 0.0;
  bool _isDragging = false;
  bool _isExpandedCard = false;
  double _touchStartY = 0.0;

  Alignment get _rotationAlignment {
    if (_touchStartY == 0.0) return Alignment.bottomCenter;
    return _touchStartY < (context.screenHeight * 0.35)
        ? Alignment.bottomCenter
        : Alignment.topCenter;
  }

  // Configuration Constants
  static const double _swipeThreshold = 120.0;
  static const double _rotationFactor = 0.04; // Adjusts card tilt intensity

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );

    _translationAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutBack));

    _rotationAnim = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // Listen to external button triggers
    widget.triggerSwipeNotifier?.addListener(_handleExternalSwipeTrigger);
  }

  @override
  void dispose() {
    widget.triggerSwipeNotifier?.removeListener(_handleExternalSwipeTrigger);
    _animController.dispose();
    super.dispose();
  }

  void _handleExternalSwipeTrigger() {
    final direction = widget.triggerSwipeNotifier?.value;
    if (direction == null || !widget.isTopCard) return;

    // Reset trigger value immediately to prevent double firing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.triggerSwipeNotifier?.value = null;
    });

    final screenWidth = context.screenWidth;
    final screenHeight = context.screenHeight;

    Offset targetOffset;
    double targetRotation;
    VoidCallback completionCallback;

    switch (direction) {
      case SwipeDirection.left:
        targetOffset = Offset(-screenWidth * 1.3, 0);
        targetRotation = -0.5;
        completionCallback = widget.onSwipeLeft;
        break;
      case SwipeDirection.right:
        targetOffset = Offset(screenWidth * 1.3, 0);
        targetRotation = 0.5;
        completionCallback = widget.onSwipeRight;
        break;
      case SwipeDirection.up:
        targetOffset = Offset(0, -screenHeight * 1.3);
        targetRotation = 0.0;
        completionCallback = widget.onSwipeUp;
        break;
    }

    _animateFlyOut(targetOffset, targetRotation, completionCallback);
  }

  void _animateFlyOut(Offset targetOffset, double targetRotation, VoidCallback onCompleted) {
    HapticFeedback.mediumImpact();
    // Reset drag notifier immediately so buttons snap back
    widget.dragOffsetNotifier?.value = Offset.zero;
    setState(() {
      _isDragging = false;
    });

    _translationAnim = Tween<Offset>(
      begin: Offset(_offsetX, _offsetY),
      end: targetOffset,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInCubic));

    _rotationAnim = Tween<double>(
      begin: _offsetX * _rotationFactor * (pi / 180),
      end: targetRotation,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.forward(from: 0.0).then((_) {
      onCompleted();
    });
  }

  void _springBack() {
    // Reset drag notifier so buttons snap back to idle
    widget.dragOffsetNotifier?.value = Offset.zero;

    _translationAnim = Tween<Offset>(
      begin: Offset(_offsetX, _offsetY),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const ElasticOutCurve(0.9), // Spring bouncy curve
    ));

    _rotationAnim = Tween<double>(
      begin: _offsetX * _rotationFactor * (pi / 180),
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _animController.forward(from: 0.0).then((_) {
      setState(() {
        _offsetX = 0.0;
        _offsetY = 0.0;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
           onPanStart: widget.isTopCard && !_isExpandedCard
               ? (details) {
                   setState(() {
                     _isDragging = true;
                     _touchStartY = details.localPosition.dy;
                   });
                   _animController.stop();
                 }
               : null,
           onPanUpdate: widget.isTopCard && !_isExpandedCard
               ? (details) {
                   setState(() {
                     _offsetX += details.delta.dx;
                     _offsetY += details.delta.dy;
                   });
                   // Notify parent of live offset for reactive button animations
                   widget.dragOffsetNotifier?.value = Offset(_offsetX, _offsetY);
                 }
               : null,
           onPanEnd: widget.isTopCard && !_isExpandedCard
               ? (_) {
                   final screenWidth = context.screenWidth;
                   final screenHeight = context.screenHeight;

                   if (_offsetX > _swipeThreshold) {
                     _animateFlyOut(Offset(screenWidth * 1.3, _offsetY), 0.4, widget.onSwipeRight);
                   } else if (_offsetX < -_swipeThreshold) {
                     _animateFlyOut(Offset(-screenWidth * 1.3, _offsetY), -0.4, widget.onSwipeLeft);
                   } else if (_offsetY < -_swipeThreshold) {
                     _animateFlyOut(Offset(_offsetX, -screenHeight * 1.3), 0.0, widget.onSwipeUp);
                   } else {
                     _springBack();
                   }
                 }
               : null,
          child: Semantics(
            label: 'Profile card of ${widget.user.name}, age ${widget.user.age}, ${widget.user.jobTitle} at ${widget.user.company}. ${widget.user.bio}. Located ${Formatter.formatDistance(widget.user.distance)} away.',
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                double currentX = _offsetX;
                double currentY = _offsetY;
                double angle = _offsetX * _rotationFactor * (pi / 180);

                if (!_isDragging && _animController.isAnimating) {
                  currentX = _translationAnim.value.dx;
                  currentY = _translationAnim.value.dy;
                  angle = _rotationAnim.value;
                }

                return Transform.translate(
                  offset: Offset(currentX, currentY),
                  child: Transform.rotate(
                    angle: angle,
                    alignment: _rotationAlignment,
                    child: child,
                  ),
                );
              },
              child: RepaintBoundary(
                child: _buildCardContent(constraints),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: context.radius.borderXxl,
        boxShadow: AppShadows.cardFloating,
        border: AppBorders.glass,
      ),
      child: ClipRRect(
        borderRadius: context.radius.borderXxl,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Immersive Photo & Detailed Scroll Sheet Transition Layout
            ProfileTransitionContainer(
              user: widget.user,
              onExpansionChanged: (isExpanded) {
                setState(() {
                  _isExpandedCard = isExpanded;
                });
              },
            ),

            // Swiping Status Stamps (LIKE / NOPE / SUPER)
            if (widget.isTopCard) ...[
              _buildLikeStamp(),
              _buildNopeStamp(),
              _buildSuperStamp(),
            ],
          ],
        ),
      ),
    );
  }

  // Stamp Builders
  Widget _buildLikeStamp() {
    double opacity = (_offsetX / _swipeThreshold).clamp(0.0, 1.0);
    if (_isDragging && _offsetX > 15) {
      return Positioned(
        top: 48,
        left: 32,
        child: Transform.rotate(
          angle: -0.2,
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.swipeLike, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LIKE',
                style: context.typography.displayMedium.copyWith(
                  color: context.colors.swipeLike,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildNopeStamp() {
    double opacity = (-_offsetX / _swipeThreshold).clamp(0.0, 1.0);
    if (_isDragging && _offsetX < -15) {
      return Positioned(
        top: 48,
        right: 32,
        child: Transform.rotate(
          angle: 0.2,
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.swipeDislike, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'NOPE',
                style: context.typography.displayMedium.copyWith(
                  color: context.colors.swipeDislike,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSuperStamp() {
    double opacity = (-_offsetY / _swipeThreshold).clamp(0.0, 1.0);
    if (_isDragging && _offsetY < -15 && _offsetX.abs() < _offsetY.abs()) {
      return Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: Center(
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.swipeSuperLike, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'SUPER LIKE',
                style: context.typography.displayMedium.copyWith(
                  color: context.colors.swipeSuperLike,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
