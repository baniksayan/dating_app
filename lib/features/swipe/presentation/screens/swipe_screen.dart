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
  final ValueNotifier<SwipeDirection?> _swipeTriggerNotifier = ValueNotifier<SwipeDirection?>(null);

  @override
  void dispose() {
    _swipeTriggerNotifier.dispose();
    super.dispose();
  }

  void _triggerButtonSwipe(SwipeDirection direction) {
    _swipeTriggerNotifier.value = direction;
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
                RepaintBoundary(
                  child: _buildTopBar(context),
                ),
                
                // Active Swipe Deck
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Leave room for floating bottom tab bar
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
          // Left: Category / Discovery selector
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
                  border: Border.all(color: context.colors.accent.withValues(alpha: 0.5)),
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

  Widget _buildSwipeDeck(BuildContext context, SwipeState state, SwipeViewModel viewModel) {
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
                      onSwipeUp: viewModel.swipeUp,
                      triggerSwipeNotifier: _swipeTriggerNotifier,
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
        RepaintBoundary(
          child: _buildActionRow(context, state, viewModel),
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context, SwipeState state, SwipeViewModel viewModel) {
    final bool canRewind = state.lastSwipedUser != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Rewind Button
          SwipeActionButton(
            icon: AppIcons.rewind,
            iconColor: canRewind ? context.colors.accent : context.colors.textSecondary.withValues(alpha: 0.3),
            size: 46,
            onTap: canRewind ? viewModel.rewind : null,
            semanticsLabel: 'Rewind last swipe',
          ),

          // 2. Dislike (Nope) Button
          SwipeActionButton(
            icon: AppIcons.dislike,
            iconColor: context.colors.swipeDislike,
            size: 56,
            onTap: state.profiles.isNotEmpty ? () => _triggerButtonSwipe(SwipeDirection.left) : null,
            semanticsLabel: 'Dislike profile',
          ),

          // 3. Super Like Button
          SwipeActionButton(
            icon: AppIcons.superlike,
            iconColor: context.colors.swipeSuperLike,
            size: 46,
            onTap: state.profiles.isNotEmpty ? () => _triggerButtonSwipe(SwipeDirection.up) : null,
            semanticsLabel: 'Super like profile',
          ),

          // 4. Like Button
          SwipeActionButton(
            icon: AppIcons.like,
            iconColor: context.colors.swipeLike,
            size: 56,
            onTap: state.profiles.isNotEmpty ? () => _triggerButtonSwipe(SwipeDirection.right) : null,
            semanticsLabel: 'Like profile',
          ),

          // 5. Boost Button - Premium stub
          SwipeActionButton(
            icon: AppIcons.boost,
            iconColor: Colors.amber,
            size: 46,
            onTap: () {
              HapticFeedback.vibrate();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: context.colors.card,
                  content: Text(
                    'Boost activated! Your profile is now visible to more people.',
                    style: context.typography.caption.copyWith(color: context.colors.textPrimary),
                  ),
                ),
              );
            },
            semanticsLabel: 'Boost profile',
          ),
        ],
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
            Text(
              'No Profiles Nearby',
              style: context.typography.title,
            ),
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

    _leftAvatarSlide = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: const Offset(0.12, 0.0), // Interlock overlap position
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _rightAvatarSlide = Tween<Offset>(
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
                          imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=400',
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
                          imageUrl: widget.matchedUser.photos.isNotEmpty ? widget.matchedUser.photos.first : '',
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
                          borderColor: context.colors.accent.withValues(alpha: 0.5),
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
