import 'dart:convert';
import 'package:dio/dio.dart';
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

  /// Undo the last swipe action (remove from likes and matches)
  Future<void> undoSwipe(String userId);

  /// Fetch 10 random mock users from randomuser.me API
  Future<List<UserModel>> fetchMockProfiles();
}

class SwipeRepositoryImpl implements SwipeRepository {
  final HiveService _hiveService;
  final Dio _dio;

  SwipeRepositoryImpl({HiveService? hiveService, Dio? dio})
      : _hiveService = hiveService ?? HiveService.instance,
        _dio = dio ?? Dio();

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

  @override
  Future<void> undoSwipe(String userId) async {
    Logger.info('Undoing swipe for user: $userId', 'SwipeRepository');
    await _hiveService.likesBox.delete(userId);
    await _hiveService.matchesBox.delete(userId);
  }

  @override
  Future<List<UserModel>> fetchMockProfiles() async {
    try {
      Logger.info('GET https://randomuser.me/api/?results=10', 'SwipeRepository');
      final response = await _dio.get(
        'https://randomuser.me/api/',
        queryParameters: {'results': 10},
        options: Options(
          headers: {
            'User-Agent': 'FlutterDatingApp/1.0 (contact@yourdomain.com)',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List<dynamic> results = data['results'] as List<dynamic>? ?? [];
        final List<UserModel> profiles = [];

        for (final result in results) {
          final Map<String, dynamic> nameMap = result['name'] as Map<String, dynamic>? ?? {};
          final String first = nameMap['first'] as String? ?? '';
          final String last = nameMap['last'] as String? ?? '';
          final String fullName = '$first $last'.trim();

          final Map<String, dynamic> dobMap = result['dob'] as Map<String, dynamic>? ?? {};
          final int age = dobMap['age'] as int? ?? 25;

          final Map<String, dynamic> pictureMap = result['picture'] as Map<String, dynamic>? ?? {};
          final String imageUrl = pictureMap['large'] as String? ?? '';

          final Map<String, dynamic> locationMap = result['location'] as Map<String, dynamic>? ?? {};
          final String city = locationMap['city'] as String? ?? 'New York';
          final String country = locationMap['country'] as String? ?? 'US';

          final Map<String, dynamic> coordinatesMap = locationMap['coordinates'] as Map<String, dynamic>? ?? {};
          final double? lat = double.tryParse(coordinatesMap['latitude'] as String? ?? '');
          final double? lon = double.tryParse(coordinatesMap['longitude'] as String? ?? '');

          final Map<String, dynamic> loginMap = result['login'] as Map<String, dynamic>? ?? {};
          final String uuid = loginMap['uuid'] as String? ?? 'user_${result['email']}';

          profiles.add(UserModel(
            id: uuid,
            name: fullName,
            age: age,
            gender: result['gender'] as String? ?? 'female',
            bio: 'Just moved here! Let\'s connect and share some stories.',
            photos: imageUrl.isNotEmpty ? [imageUrl] : const [],
            distance: 1.2,
            isVerified: true,
            isPremium: false,
            interests: const ['Travel', 'Coffee', 'Fitness', 'Music'],
            jobTitle: nameMap['title'] as String? ?? 'Member',
            company: 'RandomOrg',
            locationName: '$city, $country',
            height: 170,
            datingIntention: 'Long-term partner',
            education: 'Bachelors',
            hometown: city,
            languages: const ['English'],
            exercise: 'Active',
            diet: 'Balanced',
            pets: const ['Dogs'],
            sleepSchedule: 'Early bird',
            communicationStyle: 'Texting',
            loveLanguage: 'Quality time',
            zodiac: 'Aries',
            familyPlans: 'Someday',
            politics: 'Moderate',
            religion: 'Spiritual',
            drinking: 'Socially',
            smoking: 'No',
            personalityPrompts: const {
              'My perfect Sunday': 'Exploring new cafes and walking in the park.'
            },
            latitude: lat,
            longitude: lon,
          ));
        }
        Logger.info('Successfully parsed ${profiles.length} mock profiles from RandomUser API', 'SwipeRepository');
        return profiles;
      }
    } catch (e, stack) {
      Logger.error('Failed to fetch mock profiles from RandomUser API', e, stack, 'SwipeRepository');
    }
    return const [];
  }
}
