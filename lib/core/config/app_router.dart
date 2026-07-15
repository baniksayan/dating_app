import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/stub_screens.dart';
import '../../features/swipe/presentation/screens/swipe_screen.dart';
import '../extensions/build_context_ext.dart';
import '../theme/app_design_system.dart';
import '../widgets/glass_card.dart';

// Route Name Constants
class AppRoutes {
  AppRoutes._();
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String auth = 'auth';
  static const String otp = 'otp';

  static const String swipe = 'swipe';
  static const String explore = 'explore';
  static const String likes = 'likes';
  static const String chatList = 'chat_list';
  static const String chatDetail = 'chat_detail';
  static const String profile = 'profile';

  static const String editProfile = 'edit_profile';
  static const String gallery = 'gallery';
  static const String settings = 'settings';
  static const String premium = 'premium';
  static const String filters = 'filters';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _swipeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'swipeTab');
final GlobalKey<NavigatorState> _exploreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'exploreTab');
final GlobalKey<NavigatorState> _likesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'likesTab');
final GlobalKey<NavigatorState> _chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chatTab');
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileTab');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    // Splash Route
    GoRoute(
      path: '/',
      name: AppRoutes.splash,
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),

    // Onboarding Route
    GoRoute(
      path: '/onboarding',
      name: AppRoutes.onboarding,
      builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
    ),

    // Authentication Route
    GoRoute(
      path: '/auth',
      name: AppRoutes.auth,
      builder: (BuildContext context, GoRouterState state) => const AuthScreen(),
      routes: [
        GoRoute(
          path: 'otp',
          name: AppRoutes.otp,
          builder: (BuildContext context, GoRouterState state) => const OtpScreen(),
        ),
      ],
    ),

    // Tabbed Main Shell Layout
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
        return MainShellLayout(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        // Swipe Tab Branch
        StatefulShellBranch(
          navigatorKey: _swipeNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/swipe',
              name: AppRoutes.swipe,
              pageBuilder: (context, state) => const CupertinoPage(
                child: SwipeScreen(),
              ),
            ),
          ],
        ),

        // Explore Tab Branch
        StatefulShellBranch(
          navigatorKey: _exploreNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/explore',
              name: AppRoutes.explore,
              pageBuilder: (context, state) => const CupertinoPage(
                child: ExploreScreen(),
              ),
            ),
          ],
        ),

        // Likes Tab Branch
        StatefulShellBranch(
          navigatorKey: _likesNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/likes',
              name: AppRoutes.likes,
              pageBuilder: (context, state) => const CupertinoPage(
                child: LikesScreen(),
              ),
            ),
          ],
        ),

        // Chat Tab Branch
        StatefulShellBranch(
          navigatorKey: _chatNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/chat',
              name: AppRoutes.chatList,
              pageBuilder: (context, state) => const CupertinoPage(
                child: ChatListScreen(),
              ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'detail/:id',
                  name: AppRoutes.chatDetail,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    final id = state.pathParameters['id'] ?? '';
                    return ChatDetailScreen(chatId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Profile Tab Branch
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/profile',
              name: AppRoutes.profile,
              pageBuilder: (context, state) => const CupertinoPage(
                child: ProfileScreen(),
              ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'edit',
                  name: AppRoutes.editProfile,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'gallery',
                  name: AppRoutes.gallery,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const GalleryScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  name: AppRoutes.settings,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'premium',
                  name: AppRoutes.premium,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const PremiumScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // Filters Modal Route (placed root navigator for screen overlays)
    GoRoute(
      path: '/filters',
      name: AppRoutes.filters,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) => const FiltersScreen(),
    ),
  ],
);

/// A custom shell layout widget providing a luxurious Cupertino floating blur navigation bar.
class MainShellLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellLayout({
    super.key,
    required this.navigationShell,
  });

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      // To allow full screen cards and bottom controls to fit cleanly underneath the bottom bar:
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            blurAmount: AppBlur.heavy,
            borderRadius: AppRadius.borderPill,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            backgroundColor: const Color(0x22131110), // Ultra sheer dark brown background
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: AppIcons.swipe,
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onTabSelected(0),
                ),
                _NavBarItem(
                  icon: AppIcons.explore,
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _onTabSelected(1),
                ),
                _NavBarItem(
                  icon: AppIcons.likes,
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTabSelected(2),
                ),
                _NavBarItem(
                  icon: AppIcons.chat,
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => _onTabSelected(3),
                ),
                _NavBarItem(
                  icon: AppIcons.profile,
                  isSelected: navigationShell.currentIndex == 4,
                  onTap: () => _onTabSelected(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isSelected ? context.colors.primary : context.colors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: AppDurations.quick,
          child: Icon(
            icon,
            color: activeColor,
            size: 26,
          ),
        ),
      ),
    );
  }
}
