import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Colors, Material, Theme; // Import for basic material icons/chips if needed, otherwise paint custom
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/helpers/formatter_helper.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/profile_avatar.dart';

enum SwipeDirection { left, right, up }

class SwipeCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;
  final ValueNotifier<SwipeDirection?>? triggerSwipeNotifier;
  final bool isTopCard;

  const SwipeCard({
    super.key,
    required this.user,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
    this.triggerSwipeNotifier,
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
  int _activePhotoIndex = 0;

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

  void _handlePhotoTap(TapUpDetails details, BoxConstraints constraints) {
    final double tapX = details.localPosition.dx;
    final double width = constraints.maxWidth;

    setState(() {
      if (tapX < width * 0.4) {
        // Tap left 40% - go to previous photo
        if (_activePhotoIndex > 0) {
          _activePhotoIndex--;
          HapticFeedback.selectionClick();
        }
      } else {
        // Tap right 60% - go to next photo
        if (_activePhotoIndex < widget.user.photos.length - 1) {
          _activePhotoIndex++;
          HapticFeedback.selectionClick();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: widget.isTopCard
              ? (_) {
                  setState(() {
                    _isDragging = true;
                  });
                  _animController.stop();
                }
              : null,
          onPanUpdate: widget.isTopCard
              ? (details) {
                  setState(() {
                    _offsetX += details.delta.dx;
                    _offsetY += details.delta.dy;
                  });
                }
              : null,
          onPanEnd: widget.isTopCard
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
          onTapUp: (details) => _handlePhotoTap(details, constraints),
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
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              );
            },
            child: _buildCardContent(constraints),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(BoxConstraints constraints) {
    final String currentImageUrl = widget.user.photos.isNotEmpty
        ? widget.user.photos[_activePhotoIndex]
        : '';

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
            // Core Profile Image
            currentImageUrl.isNotEmpty
                ? Image.network(
                    currentImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: context.colors.background,
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: context.colors.divider),
                            ),
                            alignment: Alignment.center,
                            child: const Text('...', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: context.colors.card,
                        child: Center(
                          child: Icon(AppIcons.profile, size: 60, color: context.colors.textSecondary),
                        ),
                      );
                    },
                  )
                : Container(
                    color: context.colors.card,
                    child: Center(
                      child: Icon(AppIcons.profile, size: 60, color: context.colors.textSecondary),
                    ),
                  ),

            // Top gradient overlay to read photo dashes cleanly
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x7F000000),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom gradient overlay for info card readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 360,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.overlay,
                ),
              ),
            ),

            // Photos Indicators (Dashes like Instagram Stories)
            if (widget.user.photos.length > 1)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: List.generate(
                    widget.user.photos.length,
                    (index) => Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        decoration: BoxDecoration(
                          color: index == _activePhotoIndex
                              ? context.colors.primary
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Profile info content (Name, Age, Tag Chips, Job, etc.)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name & Age & Badges
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.user.name,
                            style: context.typography.displayMedium.copyWith(
                              color: context.colors.textPrimary,
                              shadows: AppShadows.textShadow,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.user.age}',
                          style: context.typography.displayMedium.copyWith(
                            color: context.colors.accent,
                            fontWeight: FontWeight.w300,
                            shadows: AppShadows.textShadow,
                          ),
                        ),
                        if (widget.user.isVerified) ...[
                          const SizedBox(width: 8),
                          const VerifiedBadge(size: 22),
                        ],
                        if (widget.user.isPremium) ...[
                          const SizedBox(width: 6),
                          const PremiumBadge(size: 22),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Location / Distance details
                    Row(
                      children: [
                        Icon(
                          AppIcons.location,
                          color: context.colors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${Formatter.formatDistance(widget.user.distance)} • ${widget.user.locationName}',
                          style: context.typography.caption.copyWith(
                            color: context.colors.textPrimary.withOpacity(0.9),
                            shadows: AppShadows.textShadow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Job Title & Company (If present)
                    if (widget.user.jobTitle.isNotEmpty) ...[
                      Text(
                        '${widget.user.jobTitle}${widget.user.company.isNotEmpty ? ' at ${widget.user.company}' : ''}',
                        style: context.typography.label.copyWith(
                          color: context.colors.accent,
                          shadows: AppShadows.textShadow,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Bio excerpt
                    if (widget.user.bio.isNotEmpty) ...[
                      Text(
                        widget.user.bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.body.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          shadows: AppShadows.textShadow,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Interest Tag Chips
                    if (widget.user.interests.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.user.interests.take(4).map((interest) {
                          return GlassCard(
                            blurAmount: AppBlur.subtle,
                            borderRadius: AppRadius.borderSm,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text(
                              interest,
                              style: context.typography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
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
