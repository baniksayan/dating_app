import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../core/widgets/swipe_action_button.dart';
import '../../../../core/config/app_router.dart';
import '../viewmodels/swipe_viewmodel.dart';
import '../widgets/swipe_card.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  // ValueNotifier to trigger fly-out animations from screen buttons
  final ValueNotifier<SwipeDirection?> _swipeTriggerNotifier =
      ValueNotifier<SwipeDirection?>(null);
  // Tracks live card drag offset — drives reactive button bubble animations
  final ValueNotifier<Offset> _dragOffsetNotifier = ValueNotifier<Offset>(
    Offset.zero,
  );

  // Boost and Super Like state variables
  bool _isBoosting = false;
  int _boostSecondsRemaining = 0;
  Timer? _boostTimer;
  bool _showBoostOverlay = false;
  bool _showBoostMiniPopup = false; // compact re-tap popup
  bool _showSuperLikeAnim = false;
  bool _superLikeTriggeredByButton = false;

  // Convenience getter: deterministically get the current user's relationship goal label
  String get _boostRelationshipGoal {
    final state = ref.read(swipeViewModelProvider);
    if (state.profiles.isEmpty) return 'your ideal match';
    final user = state.profiles.first;
    final goals = [
      'Long-term relationship',
      'Life partner',
      'Open to short-term',
      'Figuring it out',
    ];
    return goals[user.id.hashCode % goals.length];
  }

  @override
  void dispose() {
    _swipeTriggerNotifier.dispose();
    _dragOffsetNotifier.dispose();
    _boostTimer?.cancel();
    super.dispose();
  }

  void _triggerButtonSwipe(SwipeDirection direction) {
    _swipeTriggerNotifier.value = direction;
  }

  void _startBoost() {
    _boostTimer?.cancel();
    HapticFeedback.vibrate();
    setState(() {
      _isBoosting = true;
      _boostSecondsRemaining = 300; // 5 minutes
      _showBoostOverlay = true;
      _showBoostMiniPopup = false;
    });

    _boostTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_boostSecondsRemaining > 1) {
        setState(() {
          _boostSecondsRemaining--;
        });
      } else {
        _boostTimer?.cancel();
        setState(() {
          _isBoosting = false;
          _boostSecondsRemaining = 0;
        });
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final swipeState = ref.watch(swipeViewModelProvider);
    final viewModel = ref.read(swipeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          // 1. Luxury Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.background,
                    context.colors.surface,
                    context.colors.background,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content Area
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Custom Navigation Bar - Paint Isolated
                RepaintBoundary(child: _buildTopBar(context)),

                // Active Swipe Deck
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      100,
                    ), // Leave room for floating bottom tab bar
                    child: _buildSwipeDeck(context, swipeState, viewModel),
                  ),
                ),
              ],
            ),
          ),

          // 3. Match Overlay Dialog (Shown only during a Match event)
          if (swipeState.matchedUser != null)
            _MatchOverlayWidget(
              matchedUser: swipeState.matchedUser!,
              viewModel: viewModel,
            ),

          // 4. Fullscreen Super Like starburst overlay
          if (_showSuperLikeAnim)
            _SuperLikeOverlay(
              onFinished: () {
                setState(() {
                  _showSuperLikeAnim = false;
                });
                if (_superLikeTriggeredByButton) {
                  _triggerButtonSwipe(SwipeDirection.up);
                }
              },
            ),

          // 5. Fullscreen Boost countdown overlay
          if (_showBoostOverlay)
            _BoostOverlay(
              secondsRemaining: _boostSecondsRemaining,
              onClose: () {
                setState(() {
                  _showBoostOverlay = false;
                });
              },
            ),

          // 6. Mini glass popup when boost already active
          if (_showBoostMiniPopup)
            _BoostMiniPopup(
              secondsRemaining: _boostSecondsRemaining,
              relationshipGoal: _boostRelationshipGoal,
              onClose: () => setState(() => _showBoostMiniPopup = false),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Category / Discovery selector + Boost pill
          Row(
            children: [
              Text(
                'DatingApp',
                style: context.typography.headline.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.colors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colors.accent.withValues(alpha: 0.5),
                  ),
                  borderRadius: context.radius.borderPill,
                ),
                child: Text(
                  'DISCOVER',
                  style: context.typography.caption.copyWith(
                    color: context.colors.accent,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              if (_isBoosting) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4),
                    ),
                    borderRadius: context.radius.borderPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: Colors.amber,
                        size: 10,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatTime(_boostSecondsRemaining),
                        style: context.typography.caption.copyWith(
                          color: Colors.amber,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // Right: Custom Filters Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pushNamed(AppRoutes.filters);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.card,
                border: AppBorders.glass,
              ),
              child: Icon(
                AppIcons.filter,
                color: context.colors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeDeck(
    BuildContext context,
    SwipeState state,
    SwipeViewModel viewModel,
  ) {
    if (state.isLoading) {
      return Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.divider),
          ),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (state.profiles.isEmpty) {
      return _buildEmptyState(context, viewModel);
    }

    return Column(
      children: [
        // 3D Card Stack
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: List.generate(state.profiles.length, (index) {
              // Only render the top 2 cards to optimize GPU overdraw (120 FPS target)
              if (index > 1) return const SizedBox.shrink();

              final user = state.profiles[index];
              final bool isTop = index == 0;

              return Positioned.fill(
                child: AnimatedScale(
                  scale: isTop ? 1.0 : 0.95,
                  duration: AppDurations.medium,
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: AppDurations.medium,
                    curve: Curves.easeOutBack,
                    transform: Matrix4.translationValues(
                      0.0,
                      isTop ? 0.0 : 15.0,
                      0.0,
                    ),
                    child: SwipeCard(
                      key: ValueKey(user.id),
                      user: user,
                      onSwipeLeft: viewModel.swipeLeft,
                      onSwipeRight: viewModel.swipeRight,
                      onSwipeUp: () {
                        viewModel.swipeUp();
                        setState(() {
                          _showSuperLikeAnim = true;
                          _superLikeTriggeredByButton = false;
                        });
                      },
                      triggerSwipeNotifier: _swipeTriggerNotifier,
                      dragOffsetNotifier: isTop ? _dragOffsetNotifier : null,
                      isTopCard: isTop,
                    ),
                  ),
                ),
              );
            }).reversed.toList(), // Reversed so index 0 (top) is drawn last
          ),
        ),

        const SizedBox(height: 20),

        // Floating Action Controls Row - Paint Isolated
        RepaintBoundary(child: _buildActionRow(context, state, viewModel)),
      ],
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    SwipeState state,
    SwipeViewModel viewModel,
  ) {
    final bool canRewind = state.lastSwipedUser != null;
    const double swipeThreshold = 120.0; // mirrors SwipeCard._swipeThreshold

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: ValueListenableBuilder<Offset>(
        valueListenable: _dragOffsetNotifier,
        builder: (context, dragOffset, _) {
          // Progress 0→1 for each axis
          final double rightP = (dragOffset.dx / swipeThreshold).clamp(
            0.0,
            1.0,
          );
          final double leftP = (-dragOffset.dx / swipeThreshold).clamp(
            0.0,
            1.0,
          );
          final double upP = (-dragOffset.dy / swipeThreshold).clamp(0.0, 1.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. Rewind Button
              if (canRewind)
                SwipeActionButton(
                  icon: AppIcons.rewind,
                  iconColor: context.colors.accent,
                  size: 46,
                  onTap: viewModel.rewind,
                  semanticsLabel: 'Rewind last swipe',
                ),

              // 2. Dislike (Nope) — reacts to LEFT drag
              _ReactiveSwipeButton(
                icon: AppIcons.dislike,
                activeColor: context.colors.swipeDislike,
                size: 64,
                progress: leftP,
                onTap: state.profiles.isNotEmpty
                    ? () => _triggerButtonSwipe(SwipeDirection.left)
                    : null,
                semanticsLabel: 'Dislike profile',
              ),

              // 3. Super Like — reacts to UP drag
              _ReactiveSwipeButton(
                icon: AppIcons.superlike,
                activeColor: context.colors.swipeSuperLike,
                size: 46,
                progress: upP,
                onTap: state.profiles.isNotEmpty
                    ? () {
                        setState(() {
                          _showSuperLikeAnim = true;
                          _superLikeTriggeredByButton = true;
                        });
                      }
                    : null,
                semanticsLabel: 'Super like profile',
              ),

              // 4. Like (heart) — reacts to RIGHT drag
              _ReactiveSwipeButton(
                icon: AppIcons.like,
                activeColor: context.colors.swipeLike,
                size: 64,
                progress: rightP,
                onTap: state.profiles.isNotEmpty
                    ? () => _triggerButtonSwipe(SwipeDirection.right)
                    : null,
                semanticsLabel: 'Like profile',
              ),

              // 5. Boost Button — greyed while active
              _BoostActionButton(
                isBoosting: _isBoosting,
                size: 46,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (_isBoosting) {
                    setState(() => _showBoostMiniPopup = true);
                  } else {
                    _startBoost();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, SwipeViewModel viewModel) {
    return Center(
      child: GlassCard(
        blurAmount: AppBlur.medium,
        width: double.infinity,
        height: 320,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.location_slash,
              size: 54,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('No Profiles Nearby', style: context.typography.title),
            const SizedBox(height: 8),
            Text(
              'You have swiped on all users in your area. Try expanding your filters or reset the deck below.',
              style: context.typography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Reset Deck',
              width: 160,
              height: 44,
              onTap: viewModel.resetDeck,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchOverlayWidget extends StatefulWidget {
  final UserModel matchedUser;
  final SwipeViewModel viewModel;

  const _MatchOverlayWidget({
    required this.matchedUser,
    required this.viewModel,
  });

  @override
  State<_MatchOverlayWidget> createState() => _MatchOverlayWidgetState();
}

class _MatchOverlayWidgetState extends State<_MatchOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _leftAvatarSlide;
  late Animation<Offset> _rightAvatarSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _leftAvatarSlide =
        Tween<Offset>(
          begin: const Offset(-2.0, 0.0),
          end: const Offset(0.12, 0.0), // Interlock overlap position
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.9, curve: Curves.easeOutBack),
          ),
        );

    _rightAvatarSlide =
        Tween<Offset>(
          begin: const Offset(2.0, 0.0),
          end: const Offset(-0.12, 0.0), // Interlock overlap position
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.9, curve: Curves.easeOutBack),
          ),
        );

    _controller.forward();
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.vibrate();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Positioned.fill(
        child: GlassCard(
          blurAmount: AppBlur.heavy,
          backgroundColor: Colors.black.withValues(alpha: 0.85),
          border: const Border.fromBorderSide(BorderSide.none),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Title Header
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      Text(
                        'IT\'S A MATCH!',
                        style: context.typography.displayLarge.copyWith(
                          color: context.colors.accent,
                          letterSpacing: 4.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You and ${widget.matchedUser.name} liked each other.',
                        style: context.typography.body.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Side-by-side Overlapping Avatar Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Current User Stub Avatar
                    SlideTransition(
                      position: _leftAvatarSlide,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.cardFloating,
                        ),
                        child: const ProfileAvatar(
                          imageUrl:
                              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=400',
                          radius: 64,
                          isVerified: true,
                          isPremium: true,
                        ),
                      ),
                    ),

                    // Matched User Avatar
                    SlideTransition(
                      position: _rightAvatarSlide,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.cardFloating,
                        ),
                        child: ProfileAvatar(
                          imageUrl: widget.matchedUser.photos.isNotEmpty
                              ? widget.matchedUser.photos.first
                              : '',
                          radius: 64,
                          isVerified: widget.matchedUser.isVerified,
                          isPremium: widget.matchedUser.isPremium,
                        ),
                      ),
                    ),
                  ],
                ),

                // Action buttons row
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      children: [
                        PrimaryButton(
                          text: 'Send Message',
                          backgroundColor: context.colors.accent,
                          textColor: context.colors.background,
                          onTap: () {
                            widget.viewModel.dismissMatch();
                            context.pushNamed(
                              AppRoutes.chatDetail,
                              pathParameters: {'id': widget.matchedUser.id},
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SecondaryButton(
                          text: 'Keep Swiping',
                          borderColor: context.colors.accent.withValues(
                            alpha: 0.5,
                          ),
                          textColor: context.colors.accent,
                          onTap: widget.viewModel.dismissMatch,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuperLikeOverlay extends StatefulWidget {
  final VoidCallback onFinished;
  const _SuperLikeOverlay({required this.onFinished});

  @override
  State<_SuperLikeOverlay> createState() => _SuperLikeOverlayState();
}

class _SuperLikeOverlayState extends State<_SuperLikeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact(); // Double Cupertino vibe impact
    Future.delayed(
      const Duration(milliseconds: 150),
      () => HapticFeedback.mediumImpact(),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInBack)),
        weight: 40,
      ),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward().then((_) {
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: progress * 15,
              sigmaY: progress * 15,
            ),
            child: Container(
              color: Colors.black.withValues(alpha: progress * 0.45),
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4A90E2,
                                ).withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Color(0xFF4A90E2), // Premium blue star
                            size: 110,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SUPER LIKED!',
                        style: context.typography.headline.copyWith(
                          color: const Color(0xFFD2E2EC), // Soft Blue branding
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          fontSize: 24,
                          shadows: [
                            const Shadow(
                              color: Color(0xFF4A90E2),
                              blurRadius: 15,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoostOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final int secondsRemaining;

  const _BoostOverlay({required this.onClose, required this.secondsRemaining});

  @override
  State<_BoostOverlay> createState() => _BoostOverlayState();
}

class _BoostOverlayState extends State<_BoostOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    HapticFeedback.vibrate(); // Thunderstorm vibration start!

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18.0,
          sigmaY: 18.0,
        ), // iOS 26 live blur
        child: Container(
          color: Colors.black.withValues(alpha: 0.65), // Liquid glass tint
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GlassCard(
                blurAmount: AppBlur.medium,
                borderRadius: BorderRadius.circular(28),
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 0.8,
                ),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thunderstorm Bolt Icon (breathing & vibrating)
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.4),
                                    blurRadius: 25,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.bolt_rounded,
                                color: Colors.amber, // Thunderstorm yellow
                                size: 84,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'BOOST ACTIVE',
                      style: context.typography.headline.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Countdown Clock
                    Text(
                      _formatTime(widget.secondsRemaining),
                      style: context.typography.displayLarge.copyWith(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight:
                            FontWeight.w200, // Thin modern stopwatch typography
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Your profile is highlighted to nearby matches for the next 5 minutes.',
                      style: context.typography.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    PrimaryButton(
                      text: 'Keep Swiping',
                      width: double.infinity,
                      height: 48,
                      onTap: widget.onClose,
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
}

// ── Greyed-out Boost Action Button ──────────────────────────────────────────
class _BoostActionButton extends StatelessWidget {
  final bool isBoosting;
  final double size;
  final VoidCallback onTap;

  const _BoostActionButton({
    required this.isBoosting,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isBoosting ? 'Boost active' : 'Boost profile',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBoosting
                  ? const Color(0xFF2A2A2A) // Dark grey when active
                  : context.colors.card,
              border: Border.all(
                color: isBoosting
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.15),
                width: 0.8,
              ),
              boxShadow: isBoosting ? [] : AppShadows.subtle,
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                AppIcons.boost,
                key: ValueKey(isBoosting),
                color: isBoosting
                    ? Colors.white.withValues(alpha: 0.30) // Dimmed icon
                    : Colors.amber,
                size: size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Compact Glass Mini-Popup shown when already boosting ────────────────────
class _BoostMiniPopup extends StatefulWidget {
  final int secondsRemaining;
  final String relationshipGoal;
  final VoidCallback onClose;

  const _BoostMiniPopup({
    required this.secondsRemaining,
    required this.relationshipGoal,
    required this.onClose,
  });

  @override
  State<_BoostMiniPopup> createState() => _BoostMiniPopupState();
}

class _BoostMiniPopupState extends State<_BoostMiniPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose, // tap outside dismisses
        behavior: HitTestBehavior.opaque,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: Center(
              child: FadeTransition(
                opacity: _opacity,
                child: ScaleTransition(
                  scale: _scale,
                  child: GestureDetector(
                    onTap: () {}, // absorb taps on popup itself
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 22,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.15),
                            blurRadius: 32,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bolt + timer row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: Colors.amber,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _fmt(widget.secondsRemaining),
                                style: context.typography.headline.copyWith(
                                  color: Colors.amber,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your profile is boosting\ntowards your goal:',
                            style: context.typography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.relationshipGoal,
                            style: context.typography.label.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: widget.onClose,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'Got it',
                                style: context.typography.label.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reactive Swipe Button ─────────────────────────────────────────────────────
// Scales up, fills with color, and pulses a glow as the card is dragged in
// the matching direction. Returns to default when drag is released.
class _ReactiveSwipeButton extends StatefulWidget {
  final IconData icon;
  final Color activeColor;
  final double size;
  final double progress; // 0.0 → 1.0 from the drag notifier
  final VoidCallback? onTap;
  final String? semanticsLabel;

  const _ReactiveSwipeButton({
    required this.icon,
    required this.activeColor,
    required this.size,
    required this.progress,
    this.onTap,
    this.semanticsLabel,
  });

  @override
  State<_ReactiveSwipeButton> createState() => _ReactiveSwipeButtonState();
}

class _ReactiveSwipeButtonState extends State<_ReactiveSwipeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  double _prevProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Continuous slow pulse when fully triggered
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_ReactiveSwipeButton old) {
    super.didUpdateWidget(old);
    // Start pulsing when fully committed; stop when released
    if (widget.progress >= 1.0 && _prevProgress < 1.0) {
      _pulseCtrl.repeat(reverse: true);
    } else if (widget.progress < 1.0 && _prevProgress >= 1.0) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
    _prevProgress = widget.progress;
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double p = widget.progress;
    final bool active = p > 0.05;

    // Scale: idle=1.0 → triggered=1.18
    final double scale = 1.0 + (p * 0.18);

    // Background fill: card color → activeColor
    final Color bg = Color.lerp(context.colors.card, widget.activeColor, p)!;

    // Icon color: icon color → white
    final Color iconCol = Color.lerp(widget.activeColor, Colors.white, p)!;

    // Glow spread radius grows with progress
    final double glowBlur = p * 22.0;
    final double glowSpread = p * 6.0;

    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticsLabel,
      child: GestureDetector(
        onTap: widget.onTap != null
            ? () {
                HapticFeedback.mediumImpact();
                widget.onTap!();
              }
            : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              final double pulse = active ? _pulseAnim.value : 1.0;
              return Transform.scale(scale: scale * pulse, child: child);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bg,
                border: Border.all(
                  color: active
                      ? widget.activeColor.withValues(alpha: 0.5 + p * 0.5)
                      : Colors.white.withValues(alpha: 0.12),
                  width: active ? 1.5 : 0.8,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: widget.activeColor.withValues(alpha: p * 0.55),
                          blurRadius: glowBlur,
                          spreadRadius: glowSpread,
                        ),
                      ]
                    : AppShadows.subtle,
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.icon,
                color: iconCol,
                size: widget.size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
