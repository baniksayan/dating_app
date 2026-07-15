import 'dart:convert';
import '../models/user_model.dart';
import '../storage/hive_service.dart';
import '../helpers/logger_helper.dart';

abstract class SwipeRepository {
  /// Fetches profiles that have not been swiped yet (neither liked nor disliked)
  Future<List<UserModel>> getSwipeProfiles();

  /// Record a 'Like' action on a profile
  Future<void> swipeLike(String userId);

  /// Record a 'Dislike' action on a profile
  Future<void> swipeDislike(String userId);

  /// Record a 'Superlike' action on a profile
  Future<void> swipeSuperLike(String userId);

  /// Clear all swiped states and reset the deck (for testing/looping profiles)
  Future<void> resetSwipeHistory();
}

class SwipeRepositoryImpl implements SwipeRepository {
  final HiveService _hiveService;

  SwipeRepositoryImpl({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance;

  @override
  Future<List<UserModel>> getSwipeProfiles() async {
    try {
      final List<UserModel> allUsers = [];
      final userBox = _hiveService.usersBox;
      
      // Parse all users from Hive users box
      for (var key in userBox.keys) {
        final rawJson = userBox.get(key);
        if (rawJson != null) {
          final Map<String, dynamic> map = jsonDecode(rawJson as String);
          allUsers.add(UserModel.fromJson(map));
        }
      }

      // Filter out users already swiped
      final swipedBox = _hiveService.likesBox;
      final List<UserModel> unswipedUsers = allUsers.where((user) {
        return !swipedBox.containsKey(user.id);
      }).toList();

      Logger.info('Retrieved ${unswipedUsers.length} unswiped profiles out of ${allUsers.length} total profiles', 'SwipeRepository');
      return unswipedUsers;
    } catch (e, stack) {
      Logger.error('Failed to get swipe profiles', e, stack, 'SwipeRepository');
      return [];
    }
  }

  @override
  Future<void> swipeLike(String userId) async {
    Logger.info('Swiped LIKE on user: $userId', 'SwipeRepository');
    await _hiveService.likesBox.put(userId, 'like');
  }

  @override
  Future<void> swipeDislike(String userId) async {
    Logger.info('Swiped DISLIKE on user: $userId', 'SwipeRepository');
    await _hiveService.likesBox.put(userId, 'dislike');
  }

  @override
  Future<void> swipeSuperLike(String userId) async {
    Logger.info('Swiped SUPERLIKE on user: $userId', 'SwipeRepository');
    await _hiveService.likesBox.put(userId, 'superlike');
    
    // Simulate a match on Superlike for premium feel!
    await _hiveService.matchesBox.put(userId, DateTime.now().toIso8601String());
  }

  @override
  Future<void> resetSwipeHistory() async {
    Logger.info('Resetting swipe history box', 'SwipeRepository');
    await _hiveService.likesBox.clear();
    await _hiveService.matchesBox.clear();
  }
}
