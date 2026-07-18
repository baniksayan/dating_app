class OnboardingState {
  final int currentStep; // Steps: 1 to 15
  final String firstName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? interestedIn;
  final String? intention; // Dating Intention
  final int? height;
  final String? education;
  final String? hometown;
  final List<String> languages;
  final String? jobTitle;
  final String? company;
  final String? exercise;
  final String? drinking;
  final String? smoking;
  final String? diet;
  final List<String> pets;
  final String? sleepSchedule;
  final String? communicationStyle;
  final String? loveLanguage;
  final String? zodiac;
  final String? familyPlans;
  final String? politics;
  final String? religion;
  final List<String> interests;
  final List<String> photos; // Local image paths
  final Map<String, String> personalityPrompts; // prompt -> answer
  final String? openingQuestion;
  final String? openingAnswer;
  final double? latitude;
  final double? longitude;

  const OnboardingState({
    this.currentStep = 1,
    this.firstName = '',
    this.dateOfBirth,
    this.gender,
    this.interestedIn,
    this.intention,
    this.height,
    this.education,
    this.hometown,
    this.languages = const [],
    this.jobTitle = '',
    this.company = '',
    this.exercise,
    this.drinking,
    this.smoking,
    this.diet,
    this.pets = const [],
    this.sleepSchedule,
    this.communicationStyle,
    this.loveLanguage,
    this.zodiac,
    this.familyPlans,
    this.politics,
    this.religion,
    this.interests = const [],
    this.photos = const [],
    this.personalityPrompts = const {},
    this.openingQuestion,
    this.openingAnswer = '',
    this.latitude,
    this.longitude,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? firstName,
    DateTime? dateOfBirth,
    String? gender,
    bool clearGender = false,
    String? interestedIn,
    bool clearInterestedIn = false,
    String? intention,
    bool clearIntention = false,
    int? height,
    bool clearHeight = false,
    String? education,
    bool clearEducation = false,
    String? hometown,
    bool clearHometown = false,
    List<String>? languages,
    String? jobTitle,
    String? company,
    String? exercise,
    bool clearExercise = false,
    String? drinking,
    bool clearDrinking = false,
    String? smoking,
    bool clearSmoking = false,
    String? diet,
    bool clearDiet = false,
    List<String>? pets,
    String? sleepSchedule,
    bool clearSleepSchedule = false,
    String? communicationStyle,
    bool clearCommunicationStyle = false,
    String? loveLanguage,
    bool clearLoveLanguage = false,
    String? zodiac,
    bool clearZodiac = false,
    String? familyPlans,
    bool clearFamilyPlans = false,
    String? politics,
    bool clearPolitics = false,
    String? religion,
    bool clearReligion = false,
    List<String>? interests,
    List<String>? photos,
    Map<String, String>? personalityPrompts,
    String? openingQuestion,
    bool clearOpeningQuestion = false,
    String? openingAnswer,
    double? latitude,
    double? longitude,
    bool clearLatitude = false,
    bool clearLongitude = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      firstName: firstName ?? this.firstName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: clearGender ? null : (gender ?? this.gender),
      interestedIn: clearInterestedIn ? null : (interestedIn ?? this.interestedIn),
      intention: clearIntention ? null : (intention ?? this.intention),
      height: clearHeight ? null : (height ?? this.height),
      education: clearEducation ? null : (education ?? this.education),
      hometown: clearHometown ? null : (hometown ?? this.hometown),
      languages: languages ?? this.languages,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      exercise: clearExercise ? null : (exercise ?? this.exercise),
      drinking: clearDrinking ? null : (drinking ?? this.drinking),
      smoking: clearSmoking ? null : (smoking ?? this.smoking),
      diet: clearDiet ? null : (diet ?? this.diet),
      pets: pets ?? this.pets,
      sleepSchedule: clearSleepSchedule ? null : (sleepSchedule ?? this.sleepSchedule),
      communicationStyle: clearCommunicationStyle ? null : (communicationStyle ?? this.communicationStyle),
      loveLanguage: clearLoveLanguage ? null : (loveLanguage ?? this.loveLanguage),
      zodiac: zodiac ?? this.zodiac,
      familyPlans: clearFamilyPlans ? null : (familyPlans ?? this.familyPlans),
      politics: clearPolitics ? null : (politics ?? this.politics),
      religion: clearReligion ? null : (religion ?? this.religion),
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
      personalityPrompts: personalityPrompts ?? this.personalityPrompts,
      openingQuestion: clearOpeningQuestion ? null : (openingQuestion ?? this.openingQuestion),
      openingAnswer: openingAnswer ?? this.openingAnswer,
      latitude: clearLatitude ? null : (latitude ?? this.latitude),
      longitude: clearLongitude ? null : (longitude ?? this.longitude),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'firstName': firstName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'interestedIn': interestedIn,
      'intention': intention,
      'height': height,
      'education': education,
      'hometown': hometown,
      'languages': languages,
      'jobTitle': jobTitle,
      'company': company,
      'exercise': exercise,
      'drinking': drinking,
      'smoking': smoking,
      'diet': diet,
      'pets': pets,
      'sleepSchedule': sleepSchedule,
      'communicationStyle': communicationStyle,
      'loveLanguage': loveLanguage,
      'zodiac': zodiac,
      'familyPlans': familyPlans,
      'politics': politics,
      'religion': religion,
      'interests': interests,
      'photos': photos,
      'personalityPrompts': personalityPrompts,
      'openingQuestion': openingQuestion,
      'openingAnswer': openingAnswer,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      currentStep: json['currentStep'] as int? ?? 1,
      firstName: json['firstName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth'] as String) : null,
      gender: json['gender'] as String?,
      interestedIn: json['interestedIn'] as String?,
      intention: json['intention'] as String?,
      height: json['height'] as int?,
      education: json['education'] as String?,
      hometown: json['hometown'] as String?,
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      jobTitle: json['jobTitle'] as String? ?? '',
      company: json['company'] as String? ?? '',
      exercise: json['exercise'] as String?,
      drinking: json['drinking'] as String?,
      smoking: json['smoking'] as String?,
      diet: json['diet'] as String?,
      pets: (json['pets'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      sleepSchedule: json['sleepSchedule'] as String?,
      communicationStyle: json['communicationStyle'] as String?,
      loveLanguage: json['loveLanguage'] as String?,
      zodiac: json['zodiac'] as String?,
      familyPlans: json['familyPlans'] as String?,
      politics: json['politics'] as String?,
      religion: json['religion'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      personalityPrompts: (json['personalityPrompts'] as Map<dynamic, dynamic>?)?.map(
        (k, v) => MapEntry(k as String, v as String),
      ) ?? const {},
      openingQuestion: json['openingQuestion'] as String?,
      openingAnswer: json['openingAnswer'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
