import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/repositories/swipe_repository.dart';
import '../../../../core/helpers/logger_helper.dart';

class SwipeState {
  final List<UserModel> profiles;
  final bool isLoading;
  final String? errorMessage;
  final UserModel? lastSwipedUser;
  final String? lastSwipeType; // 'like', 'dislike', 'superlike'
  final UserModel? matchedUser;

  const SwipeState({
    this.profiles = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastSwipedUser,
    this.lastSwipeType,
    this.matchedUser,
  });

  SwipeState copyWith({
    List<UserModel>? profiles,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    UserModel? lastSwipedUser,
    bool clearLastSwipe = false,
    String? lastSwipeType,
    UserModel? matchedUser,
    bool clearMatch = false,
  }) {
    return SwipeState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSwipedUser: clearLastSwipe ? null : (lastSwipedUser ?? this.lastSwipedUser),
      lastSwipeType: clearLastSwipe ? null : (lastSwipeType ?? this.lastSwipeType),
      matchedUser: clearMatch ? null : (matchedUser ?? this.matchedUser),
    );
  }
}

class SwipeViewModel extends StateNotifier<SwipeState> {
  final SwipeRepository _repository;

  SwipeViewModel({required SwipeRepository repository})
      : _repository = repository,
        super(const SwipeState()) {
    loadProfiles();
  }

  /// Initial load of unswiped profiles
  Future<void> loadProfiles() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profiles = await _repository.getSwipeProfiles();
      state = state.copyWith(profiles: profiles, isLoading: false);
    } catch (e) {
      Logger.error('Failed to load swipe profiles in ViewModel', e, null, 'SwipeViewModel');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profiles. Please try again.',
      );
    }
  }

  /// Swipe Left (Dislike)
  Future<void> swipeLeft() async {
    if (state.profiles.isEmpty) return;

    final user = state.profiles.first;
    final remaining = List<UserModel>.from(state.profiles)..removeAt(0);

    state = state.copyWith(
      profiles: remaining,
      lastSwipedUser: user,
      lastSwipeType: 'dislike',
      clearMatch: true,
    );

    try {
      await _repository.swipeDislike(user.id);
    } catch (e) {
      Logger.error('Error swiping dislike', e, null, 'SwipeViewModel');
    }
  }

  /// Swipe Right (Like)
  Future<void> swipeRight() async {
    if (state.profiles.isEmpty) return;

    final user = state.profiles.first;
    final remaining = List<UserModel>.from(state.profiles)..removeAt(0);

    state = state.copyWith(
      profiles: remaining,
      lastSwipedUser: user,
      lastSwipeType: 'like',
      clearMatch: true,
    );

    try {
      await _repository.swipeLike(user.id);
      
      // Seed a random 30% match rate for normal Likes to show off the premium match overlay!
      if (user.id.hashCode % 3 == 0) {
        state = state.copyWith(matchedUser: user);
      }
    } catch (e) {
      Logger.error('Error swiping like', e, null, 'SwipeViewModel');
    }
  }

  /// Swipe Up (Super Like) - Instantly triggers a match in our seed demo
  Future<void> swipeUp() async {
    if (state.profiles.isEmpty) return;

    final user = state.profiles.first;
    final remaining = List<UserModel>.from(state.profiles)..removeAt(0);

    state = state.copyWith(
      profiles: remaining,
      lastSwipedUser: user,
      lastSwipeType: 'superlike',
      matchedUser: user, // 100% Match for Superlikes in demo
    );

    try {
      await _repository.swipeSuperLike(user.id);
    } catch (e) {
      Logger.error('Error swiping superlike', e, null, 'SwipeViewModel');
    }
  }

  /// Rewind the last action (Undo swipe)
  Future<void> rewind() async {
    final lastUser = state.lastSwipedUser;
    final lastType = state.lastSwipeType;

    if (lastUser == null || lastType == null) {
      Logger.warning('No swipe history to rewind', 'SwipeViewModel');
      return;
    }

    // Pull the user back to the top of the swipe deck
    final updatedProfiles = [lastUser, ...state.profiles];

    state = state.copyWith(
      profiles: updatedProfiles,
      clearLastSwipe: true,
      clearMatch: true,
    );

    try {
      // Remove swipe history record in the repository
      // Resetting the specific key in Hive
      final likesBox = SwipeRepositoryImpl()._hiveService.likesBox;
      final matchesBox = SwipeRepositoryImpl()._hiveService.matchesBox;
      await likesBox.delete(lastUser.id);
      await matchesBox.delete(lastUser.id);
      Logger.info('Successfully rewound swipe for ${lastUser.name}', 'SwipeViewModel');
    } catch (e) {
      Logger.error('Error rewinding swipe', e, null, 'SwipeViewModel');
    }
  }

  /// Reset all swiped history to retry swiping
  Future<void> resetDeck() async {
    state = state.copyWith(isLoading: true, clearLastSwipe: true, clearMatch: true);
    try {
      await _repository.resetSwipeHistory();
      final profiles = await _repository.getSwipeProfiles();
      state = state.copyWith(profiles: profiles, isLoading: false);
    } catch (e) {
      Logger.error('Error resetting deck', e, null, 'SwipeViewModel');
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to reset deck.');
    }
  }

  /// Dismiss active match overlay
  void dismissMatch() {
    state = state.copyWith(clearMatch: true);
  }
}

// Riverpod Providers
final swipeRepositoryProvider = Provider<SwipeRepository>((ref) {
  return SwipeRepositoryImpl();
});

final swipeViewModelProvider = StateNotifierProvider<SwipeViewModel, SwipeState>((ref) {
  final repository = ref.watch(swipeRepositoryProvider);
  return SwipeViewModel(repository: repository);
});
