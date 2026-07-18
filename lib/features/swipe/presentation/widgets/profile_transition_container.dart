import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Colors;
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/models/user_model.dart';
import 'floating_expand_button.dart';
import 'profile_photo_gallery.dart';
import 'profile_scroll_sheet.dart';

class ProfileTransitionContainer extends StatefulWidget {
  final UserModel user;
  final ValueChanged<bool> onExpansionChanged;

  const ProfileTransitionContainer({
    super.key,
    required this.user,
    required this.onExpansionChanged,
  });

  @override
  State<ProfileTransitionContainer> createState() => _ProfileTransitionContainerState();
}

class _ProfileTransitionContainerState extends State<ProfileTransitionContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  late ScrollController _scrollController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.fastOutSlowIn,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // If expanded and pulled down past top bounds (iOS bounce physics), collapse
    if (_scrollController.offset < -60.0 && _isExpanded) {
      _toggleExpanded(false);
    }
  }

  void _toggleExpanded(bool expand) {
    if (_isExpanded == expand) return;

    setState(() {
      _isExpanded = expand;
    });

    widget.onExpansionChanged(expand);

    if (expand) {
      _animController.forward();
    } else {
      _animController.reverse();
      // Scroll back to top smoothly
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: AppDurations.quick,
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardHeight = constraints.maxHeight;
        
        // Bounded overlay details panel height when collapsed
        const double collapsedHeight = 180.0;
        final double collapsedTop = cardHeight - collapsedHeight;

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final double value = _animation.value;
            
            // 1. Sliding sheet top offset from collapsed state to fullscreen (0.0)
            final double sheetTop = collapsedTop - (collapsedTop * value);
            
            // 2. Parallax vertical shift downward
            final double photoParallax = value * (cardHeight * 0.10);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Full-screen background photo with parallax
                Positioned(
                  top: photoParallax,
                  bottom: -photoParallax,
                  left: 0,
                  right: 0,
                  child: ProfilePhotoGallery(
                    photos: widget.user.photos,
                    userId: widget.user.id,
                  ),
                ),

                // 2. iOS 26 Liquid Glass - Live Blur Overlay
                // Starts 24px above sheetTop so the Name and Bio preview sit on the blurred glass surface
                Positioned(
                  left: 0,
                  right: 0,
                  top: max(0.0, sheetTop - 24.0),
                  bottom: 0,
                  child: ClipRect(
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        // Dynamic gradient stops based on expansion progress
                        // High-density blur starts right at the top edge of overlay area
                        final double start = (1.0 - value) * 0.05;
                        final double end = (1.0 - value) * 0.20;
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: const [Colors.transparent, Colors.black],
                          stops: [start, max(start + 0.01, end)],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.45 + (0.35 * value)),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Transparent detail sheet floating on top of the live blur overlay
                Positioned(
                  left: 0,
                  right: 0,
                  top: sheetTop,
                  bottom: 0,
                  child: ProfileScrollSheet(
                    user: widget.user,
                    isExpanded: _isExpanded,
                    scrollController: _scrollController,
                    onExpandTap: () => _toggleExpanded(!_isExpanded),
                  ),
                ),

                // 4. Fixed float expand button at bottom-right of card - ONLY visible when expanded
                if (_isExpanded)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: FloatingExpandButton(
                      isExpanded: _isExpanded,
                      onTap: () => _toggleExpanded(!_isExpanded),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
