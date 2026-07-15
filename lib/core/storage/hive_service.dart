import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../helpers/logger_helper.dart';

class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();

  // Box Names
  static const String _usersBoxName = 'users_box';
  static const String _likesBoxName = 'likes_box';
  static const String _matchesBoxName = 'matches_box';
  static const String _settingsBoxName = 'settings_box';

  late Box _usersBox;
  late Box _likesBox;
  late Box _matchesBox;
  late Box _settingsBox;

  Box get usersBox => _usersBox;
  Box get likesBox => _likesBox;
  Box get matchesBox => _matchesBox;
  Box get settingsBox => _settingsBox;

  /// Initialize Hive and open all boxes
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      _usersBox = await Hive.openBox(_usersBoxName);
      _likesBox = await Hive.openBox(_likesBoxName);
      _matchesBox = await Hive.openBox(_matchesBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);

      Logger.info('Hive Initialized Successfully', 'HiveService');
      
      // Seed dummy data if empty
      if (_usersBox.isEmpty) {
        await _seedMockData();
      }
    } catch (e, stack) {
      Logger.error('Failed to initialize Hive', e, stack, 'HiveService');
    }
  }

  /// Seeds mock dating profiles into the Hive user box
  Future<void> _seedMockData() async {
    Logger.info('Seeding mock profiles into Hive...', 'HiveService');
    
    final List<Map<String, dynamic>> mockProfiles = [
      {
        'id': 'user_1',
        'name': 'Aurelia',
        'age': 24,
        'gender': 'female',
        'bio': 'Fine arts curator from Paris, currently in NY. Passionate about minimalism, architectural design, and espresso. Let’s explore a gallery together.',
        'photos': [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=600',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80&w=600',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=600',
        ],
        'distance': 1.8,
        'isVerified': true,
        'isPremium': true,
        'interests': ['Art', 'Design', 'Architecture', 'Travel', 'Espresso'],
        'jobTitle': 'Art Curator',
        'company': 'MoMA',
        'locationName': 'Manhattan, New York',
      },
      {
        'id': 'user_2',
        'name': 'Sebastian',
        'age': 27,
        'gender': 'male',
        'bio': 'Architectural designer. Seeking elegance in structure and depth in conversation. Usually sketching, traveling, or playing jazz piano.',
        'photos': [
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=600',
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=600',
        ],
        'distance': 3.4,
        'isVerified': true,
        'isPremium': false,
        'interests': ['Sketching', 'Jazz Piano', 'Brutalism', 'Vinyl', 'Sailing'],
        'jobTitle': 'Senior Architect',
        'company': 'Foster + Partners',
        'locationName': 'Brooklyn, New York',
      },
      {
        'id': 'user_3',
        'name': 'Isabella',
        'age': 26,
        'gender': 'female',
        'bio': 'UX researcher by day, classical violinist by night. Let’s find harmony in code, design, and symphony.',
        'photos': [
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=600',
          'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&q=80&w=600',
        ],
        'distance': 0.8,
        'isVerified': true,
        'isPremium': true,
        'interests': ['Violin', 'Human Behavior', 'Indie Rock', 'Hike', 'Matcha'],
        'jobTitle': 'Staff UX Researcher',
        'company': 'Apple',
        'locationName': 'Greenwich Village, New York',
      },
      {
        'id': 'user_4',
        'name': 'Julian',
        'age': 29,
        'gender': 'male',
        'bio': 'Software engineer and private pilot. Coding clean code on ground, flying single-engines in skies. Love deep house, road trips, and vinyl records.',
        'photos': [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=600',
          'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&q=80&w=600',
        ],
        'distance': 5.2,
        'isVerified': false,
        'isPremium': false,
        'interests': ['Aviation', 'Deep House', 'Road Trips', 'Flutter', 'Fitness'],
        'jobTitle': 'Architect Engineer',
        'company': 'Vercel',
        'locationName': 'Chelsea, New York',
      },
      {
        'id': 'user_5',
        'name': 'Seraphina',
        'age': 25,
        'gender': 'female',
        'bio': 'Creating tactile poetry through fabrics. Fashion designer inspired by vintage aesthetics, film photography, and rainy Sunday afternoons.',
        'photos': [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=600',
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&q=80&w=600',
        ],
        'distance': 2.1,
        'isVerified': true,
        'isPremium': true,
        'interests': ['Fashion', 'Film Photography', 'Thrifting', 'Vinyl', 'Tea Tasting'],
        'jobTitle': 'Lead Designer',
        'company': 'Self-Employed',
        'locationName': 'SoHo, New York',
      }
    ];

    for (final profile in mockProfiles) {
      await _usersBox.put(profile['id'], jsonEncode(profile));
    }
    
    Logger.info('Successfully seeded ${_usersBox.length} mock profiles', 'HiveService');
  }

  /// Reset Hive databases for testing or user logging out
  Future<void> clearAll() async {
    await _usersBox.clear();
    await _likesBox.clear();
    await _matchesBox.clear();
    await _settingsBox.clear();
    await _seedMockData(); // Reseed immediately
  }
}
