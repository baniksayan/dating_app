import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/helpers/logger_helper.dart';
import '../models/onboarding_state.dart';
import '../repositories/location_repository.dart';

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final HiveService _hiveService;
  final LocationRepository _locationRepository;

  OnboardingViewModel({
    HiveService? hiveService,
    LocationRepository? locationRepository,
  })  : _hiveService = hiveService ?? HiveService.instance,
        _locationRepository = locationRepository ?? PhotonLocationRepository(),
        super(const OnboardingState()) {
    _loadDraft();
  }

  static const String _draftKey = 'onboarding_draft';

  // Load draft onboarding progress from local Hive storage
  void _loadDraft() {
    try {
      final rawDraft = _hiveService.settingsBox.get(_draftKey);
      if (rawDraft != null) {
        final Map<String, dynamic> map = jsonDecode(rawDraft as String);
        state = OnboardingState.fromJson(map);
        Logger.info('Loaded onboarding draft starting at step ${state.currentStep}', 'OnboardingViewModel');
      }
    } catch (e, stack) {
      Logger.error('Failed to load onboarding draft', e, stack, 'OnboardingViewModel');
    }
  }

  // Save active progress draft to Hive settings box
  void _saveDraft() {
    try {
      final rawJson = jsonEncode(state.toJson());
      _hiveService.settingsBox.put(_draftKey, rawJson);
    } catch (e, stack) {
      Logger.error('Failed to save onboarding draft', e, stack, 'OnboardingViewModel');
    }
  }

  void nextStep() {
    if (state.currentStep < 15) {
      state = state.copyWith(currentStep: state.currentStep + 1);
      _saveDraft();
    }
  }

  void prevStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
      _saveDraft();
    }
  }

  void jumpToStep(int step) {
    if (step >= 1 && step <= 15) {
      state = state.copyWith(currentStep: step);
      _saveDraft();
    }
  }

  void updateFirstName(String name) {
    state = state.copyWith(firstName: name.trim());
    _saveDraft();
  }

  void updateDateOfBirth(DateTime dob) {
    // Automatically compute Zodiac sign from DOB
    final zodiacSign = getZodiacSign(dob);
    state = state.copyWith(
      dateOfBirth: dob,
      zodiac: zodiacSign,
    );
    _saveDraft();
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
    _saveDraft();
  }

  void updateInterestedIn(String interest) {
    state = state.copyWith(interestedIn: interest);
    _saveDraft();
  }

  void updateIntention(String intention) {
    state = state.copyWith(intention: intention);
    _saveDraft();
  }

  void updateHeight(int? height) {
    if (height == null) {
      state = state.copyWith(clearHeight: true);
    } else {
      state = state.copyWith(height: height);
    }
    _saveDraft();
  }

  void updateEducation(String? education) {
    if (education == null) {
      state = state.copyWith(clearEducation: true);
    } else {
      state = state.copyWith(education: education);
    }
    _saveDraft();
  }

  void updateHometown(String? hometown) {
    if (hometown == null) {
      state = state.copyWith(clearHometown: true);
    } else {
      state = state.copyWith(hometown: hometown);
    }
    _saveDraft();
  }

  void updateLanguages(List<String> languages) {
    state = state.copyWith(languages: languages);
    _saveDraft();
  }

  void updateJobTitle(String title) {
    state = state.copyWith(jobTitle: title.trim());
    _saveDraft();
  }

  void updateCompany(String company) {
    state = state.copyWith(company: company.trim());
    _saveDraft();
  }

  void updateExercise(String? exercise) {
    if (exercise == null) {
      state = state.copyWith(clearExercise: true);
    } else {
      state = state.copyWith(exercise: exercise);
    }
    _saveDraft();
  }

  void updateDrinking(String? drinking) {
    if (drinking == null) {
      state = state.copyWith(clearDrinking: true);
    } else {
      state = state.copyWith(drinking: drinking);
    }
    _saveDraft();
  }

  void updateSmoking(String? smoking) {
    if (smoking == null) {
      state = state.copyWith(clearSmoking: true);
    } else {
      state = state.copyWith(smoking: smoking);
    }
    _saveDraft();
  }

  void updateDiet(String? diet) {
    if (diet == null) {
      state = state.copyWith(clearDiet: true);
    } else {
      state = state.copyWith(diet: diet);
    }
    _saveDraft();
  }

  void updatePets(List<String> pets) {
    state = state.copyWith(pets: pets);
    _saveDraft();
  }

  void updateSleepSchedule(String? sleep) {
    if (sleep == null) {
      state = state.copyWith(clearSleepSchedule: true);
    } else {
      state = state.copyWith(sleepSchedule: sleep);
    }
    _saveDraft();
  }

  void updateCommunicationStyle(String? style) {
    if (style == null) {
      state = state.copyWith(clearCommunicationStyle: true);
    } else {
      state = state.copyWith(communicationStyle: style);
    }
    _saveDraft();
  }

  void updateLoveLanguage(String? love) {
    if (love == null) {
      state = state.copyWith(clearLoveLanguage: true);
    } else {
      state = state.copyWith(loveLanguage: love);
    }
    _saveDraft();
  }

  void updateFamilyPlans(String? plans) {
    if (plans == null) {
      state = state.copyWith(clearFamilyPlans: true);
    } else {
      state = state.copyWith(familyPlans: plans);
    }
    _saveDraft();
  }

  void updatePolitics(String? politics) {
    if (politics == null) {
      state = state.copyWith(clearPolitics: true);
    } else {
      state = state.copyWith(politics: politics);
    }
    _saveDraft();
  }

  void updateReligion(String? religion) {
    if (religion == null) {
      state = state.copyWith(clearReligion: true);
    } else {
      state = state.copyWith(religion: religion);
    }
    _saveDraft();
  }

  void toggleInterest(String interest) {
    final List<String> updated = List.from(state.interests);
    if (updated.contains(interest)) {
      updated.remove(interest);
    } else {
      updated.add(interest);
    }
    state = state.copyWith(interests: updated);
    _saveDraft();
  }

  void addPhoto(String path) {
    final List<String> updated = List.from(state.photos);
    if (updated.length < 6) {
      updated.add(path);
      state = state.copyWith(photos: updated);
      _saveDraft();
    }
  }

  void removePhoto(int index) {
    final List<String> updated = List.from(state.photos);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(photos: updated);
      _saveDraft();
    }
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    final List<String> updated = List.from(state.photos);
    if (oldIndex >= 0 && oldIndex < updated.length && newIndex >= 0 && newIndex <= updated.length) {
      int targetIndex = newIndex;
      if (oldIndex < newIndex) {
        targetIndex -= 1;
      }
      final String item = updated.removeAt(oldIndex);
      updated.insert(targetIndex, item);
      state = state.copyWith(photos: updated);
      _saveDraft();
    }
  }

  void updatePersonalityPrompt(String question, String answer) {
    final Map<String, String> updated = Map.from(state.personalityPrompts);
    if (answer.trim().isEmpty) {
      updated.remove(question);
    } else {
      updated[question] = answer.trim();
    }
    state = state.copyWith(personalityPrompts: updated);
    _saveDraft();
  }

  void updateOpeningMove(String? question, String answer) {
    if (question == null) {
      state = state.copyWith(
        clearOpeningQuestion: true,
        openingAnswer: '',
      );
    } else {
      state = state.copyWith(
        openingQuestion: question,
        openingAnswer: answer,
      );
    }
    _saveDraft();
  }

  // Calculate zodiac sign utility from birthdate
  String getZodiacSign(DateTime date) {
    final int month = date.month;
    final int day = date.day;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries ♈';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus ♉';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini ♊';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer ♋';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo ♌';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo ♍';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra ♎';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio ♏';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius ♐';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn ♑';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius ♒';
    return 'Pisces ♓';
  }

  bool get isAgeValid {
    final dob = state.dateOfBirth;
    if (dob == null) return false;
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age >= 18;
  }

  int get calculatedAge {
    final dob = state.dateOfBirth;
    if (dob == null) return 0;
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  // Calculate profile completeness score (0.0 to 1.0)
  double get profileCompleteness {
    double score = 0.0;
    
    // Core details (40% total)
    if (state.firstName.isNotEmpty) score += 0.1;
    if (state.dateOfBirth != null && isAgeValid) score += 0.1;
    if (state.gender != null && state.interestedIn != null) score += 0.1;
    if (state.photos.length >= 4) score += 0.1;

    // Optional attributes (60% total)
    if (state.intention != null) score += 0.05;
    if (state.height != null) score += 0.05;
    if (state.education != null) score += 0.05;
    if (state.hometown != null && state.hometown!.isNotEmpty) score += 0.05;
    if (state.languages.isNotEmpty) score += 0.05;
    if (state.jobTitle != null && state.jobTitle!.isNotEmpty) score += 0.05;
    
    // Habits group (10% total - 2% each)
    if (state.drinking != null) score += 0.02;
    if (state.smoking != null) score += 0.02;
    if (state.diet != null) score += 0.02;
    if (state.exercise != null) score += 0.02;
    if (state.sleepSchedule != null) score += 0.02;

    if (state.familyPlans != null) score += 0.05;
    if (state.communicationStyle != null) score += 0.025;
    if (state.loveLanguage != null) score += 0.025;
    
    if (state.religion != null || state.politics != null) score += 0.05;
    if (state.interests.length >= 3) score += 0.05;
    if (state.personalityPrompts.length >= 2) score += 0.05;
    if (state.openingQuestion != null && state.openingAnswer!.isNotEmpty) score += 0.05;

    return score.clamp(0.0, 1.0);
  }

  Future<Position?> detectUserLocation() async {
    try {
      final position = await _locationRepository.getCurrentLocation();
      if (position != null) {
        state = state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _saveDraft();
        return position;
      }
    } catch (e, stack) {
      Logger.error('Failed to detect user location', e, stack, 'OnboardingViewModel');
    }
    return null;
  }

  bool isStepValid(int step) {
    switch (step) {
      case 1: // Name
        return state.firstName.isNotEmpty && state.firstName.length >= 2;
      case 2: // Birthday
        return isAgeValid;
      case 3: // Gender & preference
        return state.gender != null && state.interestedIn != null;
      case 4: // Dating Intention
        return state.intention != null;
      case 5: // Background (height, hometown, languages) - optional
        return true;
      case 6: // Education & career - optional
        return true;
      case 7: // Habits - optional
        return true;
      case 8: // Family plans - optional
        return true;
      case 9: // Communication & Love Language - optional
        return true;
      case 10: // Faith & Values - optional
        return true;
      case 11: // Interests
        return state.interests.length >= 3;
      case 12: // Photos
        return state.photos.length >= 4;
      case 13: // Personality Prompts (require at least 2 answers if they don't skip)
        // Note: they can skip or next, but we will make it valid.
        return true;
      case 14: // Opening Move - optional
        return true;
      case 15: // Preview - always valid
        return true;
      default:
        return false;
    }
  }

  /// Finalize profile onboarding and register user session
  Future<bool> completeOnboarding() async {
    try {
      // Create new UserModel populated from all onboarding inputs
      final newUser = UserModel(
        id: 'user_onboarded_${DateTime.now().millisecondsSinceEpoch}',
        name: state.firstName,
        age: calculatedAge,
        gender: state.gender ?? 'non-binary',
        bio: state.personalityPrompts.isNotEmpty
            ? state.personalityPrompts.entries.map((e) => '${e.key}: "${e.value}"').join('\n\n')
            : 'Looking to connect and share new memories.',
        photos: state.photos.isNotEmpty 
            ? state.photos 
            : ['https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=600'],
        distance: 1.2,
        isVerified: false,
        isPremium: false,
        interests: state.interests,
        jobTitle: state.jobTitle?.isNotEmpty == true ? state.jobTitle! : 'Member',
        company: state.company?.isNotEmpty == true ? state.company! : 'DatingApp',
        locationName: state.hometown ?? 'New York, NY',
        height: state.height,
        datingIntention: state.intention,
        latitude: state.latitude,
        longitude: state.longitude,
        education: state.education,
        hometown: state.hometown,
        languages: state.languages,
        exercise: state.exercise,
        diet: state.diet,
        pets: state.pets,
        sleepSchedule: state.sleepSchedule,
        communicationStyle: state.communicationStyle,
        loveLanguage: state.loveLanguage,
        zodiac: state.zodiac,
        familyPlans: state.familyPlans,
        politics: state.politics,
        religion: state.religion,
        drinking: state.drinking,
        smoking: state.smoking,
        personalityPrompts: state.personalityPrompts,
        openingMove: state.openingQuestion != null && state.openingAnswer!.isNotEmpty
            ? {'question': state.openingQuestion!, 'answer': state.openingAnswer!}
            : null,
      );

      // Save user to Hive users database
      await _hiveService.usersBox.put(newUser.id, jsonEncode(newUser.toJson()));
      
      // Update session onboarding status flags
      await _hiveService.settingsBox.put('is_onboarding_completed', true);
      
      // Reset seen tutorial flag to false so the tutorial runs exactly once
      await _hiveService.settingsBox.put('has_seen_swipe_tutorial', false);
      
      // Delete draft key
      await _hiveService.settingsBox.delete(_draftKey);

      Logger.info('Successfully completed onboarding for ${newUser.name}', 'OnboardingViewModel');
      return true;
    } catch (e, stack) {
      Logger.error('Failed to complete onboarding', e, stack, 'OnboardingViewModel');
      return false;
    }
  }
}

// Riverpod Provider for OnboardingViewModel
final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  final locationRepo = ref.read(locationRepositoryProvider);
  return OnboardingViewModel(locationRepository: locationRepo);
});
