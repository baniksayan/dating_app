import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dating_app/core/models/user_model.dart';
import 'package:dating_app/core/repositories/swipe_repository.dart';
import 'package:dating_app/features/swipe/presentation/viewmodels/swipe_viewmodel.dart';
import 'package:dating_app/features/swipe/presentation/widgets/profile_transition_container.dart';
import 'package:dating_app/features/swipe/presentation/widgets/floating_expand_button.dart';

// Create a Fake implementation of SwipeRepository for Unit Testing
class FakeSwipeRepository implements SwipeRepository {
  final List<UserModel> dummyUsers = [
    const UserModel(
      id: 'test_1',
      name: 'Alice',
      age: 23,
      gender: 'female',
      bio: 'Bio 1',
      photos: ['photo_1.jpg'],
      distance: 1.0,
      isVerified: true,
      isPremium: false,
      interests: [],
      jobTitle: '',
      company: '',
      locationName: '',
    ),
    const UserModel(
      id: 'test_2',
      name: 'Bob',
      age: 25,
      gender: 'male',
      bio: 'Bio 2',
      photos: ['photo_2.jpg'],
      distance: 2.5,
      isVerified: false,
      isPremium: true,
      interests: [],
      jobTitle: '',
      company: '',
      locationName: '',
    ),
  ];

  @override
  Future<List<UserModel>> getSwipeProfiles() async {
    return List<UserModel>.from(dummyUsers);
  }

  @override
  Future<void> swipeLike(String userId) async {}

  @override
  Future<void> swipeDislike(String userId) async {}

  @override
  Future<void> swipeSuperLike(String userId) async {}
  @override
  Future<void> resetSwipeHistory() async {}

  @override
  Future<void> undoSwipe(String userId) async {}
}
void main() {
  group('SwipeViewModel Unit Tests', () {
    late FakeSwipeRepository repository;
    late SwipeViewModel viewModel;

    setUp(() {
      repository = FakeSwipeRepository();
      viewModel = SwipeViewModel(repository: repository);
    });

    test('Initial state loads swipe profiles correctly', () async {
      // Allow async initial load in constructor to complete
      await Future.delayed(Duration.zero);

      expect(viewModel.state.profiles.length, 2);
      expect(viewModel.state.profiles.first.name, 'Alice');
      expect(viewModel.state.isLoading, false);
    });

    test('Swipe left removes the top card and records it in history', () async {
      await Future.delayed(Duration.zero);

      final topUser = viewModel.state.profiles.first;

      await viewModel.swipeLeft();

      expect(viewModel.state.profiles.length, 1);
      expect(viewModel.state.profiles.first.name, 'Bob');
      expect(viewModel.state.lastSwipedUser, topUser);
      expect(viewModel.state.lastSwipeType, 'dislike');
    });

    test('Swipe right triggers possible match checks and updates deck', () async {
      await Future.delayed(Duration.zero);

      await viewModel.swipeRight();

      expect(viewModel.state.profiles.length, 1);
      expect(viewModel.state.lastSwipeType, 'like');
    });

    test('Rewind returns the last swiped user back to the top of deck', () async {
      await Future.delayed(Duration.zero);

      final topUser = viewModel.state.profiles.first;

      await viewModel.swipeLeft(); // Swipe Alice left
      expect(viewModel.state.profiles.first.name, 'Bob');

      await viewModel.rewind(); // Undo swipe

      expect(viewModel.state.profiles.length, 2);
      expect(viewModel.state.profiles.first, topUser);
      expect(viewModel.state.lastSwipedUser, null);
      expect(viewModel.state.lastSwipeType, null);
    });
  });

  group('Swipe Card Widget Tests', () {
    testWidgets('ProfileTransitionContainer layout and expansion tests', (WidgetTester tester) async {
      const user = UserModel(
        id: 'test_user',
        name: 'Charlotte',
        age: 26,
        gender: 'female',
        bio: 'Charlotte biography details here.',
        photos: [],
        distance: 4.2,
        isVerified: true,
        isPremium: true,
        interests: ['Hiking', 'Art'],
        jobTitle: 'Product Designer',
        company: 'Apple',
        locationName: 'Cupertino',
      );

      bool expansionChangedCalled = false;
      bool isExpandedResult = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              child: SizedBox(
                width: 375,
                height: 600,
                child: ProfileTransitionContainer(
                  user: user,
                  onExpansionChanged: (val) {
                    expansionChangedCalled = true;
                    isExpandedResult = val;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Verify name, age, job details are rendered
      expect(find.text('Charlotte, 26'), findsOneWidget);
      expect(find.text('Product Designer at Apple'), findsOneWidget);
      expect(find.text('Cupertino • 4.2 miles away'), findsOneWidget);

      // Details section should NOT be present (since it is collapsed initially)
      expect(find.text('The Basics'), findsNothing);
      expect(find.text('Lifestyle'), findsNothing);

      // Find the expand button (FloatingExpandButton) and tap it
      final buttonFinder = find.byType(FloatingExpandButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump(); // Process tap gesture synchronously

      try {
        // Verify expansion callback was called
        expect(expansionChangedCalled, true);
        expect(isExpandedResult, true);

        // Details sections should now be present (expanded state)
        expect(find.text('The Basics'), findsOneWidget);
        expect(find.text('Lifestyle'), findsOneWidget);
      } finally {
        // Disposes of the widget tree, which stops the infinite pulse animation timers
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  });
}
