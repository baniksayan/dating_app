class UserModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bio;
  final List<String> photos;
  final double distance;
  final bool isVerified;
  final bool isPremium;
  final List<String> interests;
  final String jobTitle;
  final String company;
  final String locationName;
  final int? height; // in cm
  final String? datingIntention;
  final String? education;
  final String? hometown;
  final List<String>? languages;
  final String? exercise;
  final String? diet;
  final List<String>? pets;
  final String? sleepSchedule;
  final String? communicationStyle;
  final String? loveLanguage;
  final String? zodiac;
  final String? familyPlans;
  final String? politics;
  final String? religion;
  final String? drinking;
  final String? smoking;
  final Map<String, String>? personalityPrompts;
  final Map<String, String>? openingMove;
  final DateTime? createdAt;
  final double? latitude;
  final double? longitude;

  String get displayName {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return name;
    if (parts.length == 2) {
      final first = parts[0];
      final last = parts[1];
      if (last.isNotEmpty) {
        return '$first ${last[0].toUpperCase()}';
      }
    } else if (parts.length >= 3) {
      final first = parts[0];
      final last = parts[parts.length - 1];
      if (last.isNotEmpty) {
        return '$first ${last[0].toUpperCase()}..';
      }
    }
    return name;
  }

  const UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bio,
    required this.photos,
    required this.distance,
    required this.isVerified,
    required this.isPremium,
    required this.interests,
    required this.jobTitle,
    required this.company,
    required this.locationName,
    this.height,
    this.datingIntention,
    this.education,
    this.hometown,
    this.languages,
    this.exercise,
    this.diet,
    this.pets,
    this.sleepSchedule,
    this.communicationStyle,
    this.loveLanguage,
    this.zodiac,
    this.familyPlans,
    this.politics,
    this.religion,
    this.drinking,
    this.smoking,
    this.personalityPrompts,
    this.openingMove,
    this.createdAt,
    this.latitude,
    this.longitude,
  });

  UserModel copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? bio,
    List<String>? photos,
    double? distance,
    bool? isVerified,
    bool? isPremium,
    List<String>? interests,
    String? jobTitle,
    String? company,
    String? locationName,
    int? height,
    String? datingIntention,
    String? education,
    String? hometown,
    List<String>? languages,
    String? exercise,
    String? diet,
    List<String>? pets,
    String? sleepSchedule,
    String? communicationStyle,
    String? loveLanguage,
    String? zodiac,
    String? familyPlans,
    String? politics,
    String? religion,
    String? drinking,
    String? smoking,
    Map<String, String>? personalityPrompts,
    Map<String, String>? openingMove,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    bool clearLatitude = false,
    bool clearLongitude = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      distance: distance ?? this.distance,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      interests: interests ?? this.interests,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      locationName: locationName ?? this.locationName,
      height: height ?? this.height,
      datingIntention: datingIntention ?? this.datingIntention,
      education: education ?? this.education,
      hometown: hometown ?? this.hometown,
      languages: languages ?? this.languages,
      exercise: exercise ?? this.exercise,
      diet: diet ?? this.diet,
      pets: pets ?? this.pets,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      loveLanguage: loveLanguage ?? this.loveLanguage,
      zodiac: zodiac ?? this.zodiac,
      familyPlans: familyPlans ?? this.familyPlans,
      politics: politics ?? this.politics,
      religion: religion ?? this.religion,
      drinking: drinking ?? this.drinking,
      smoking: smoking ?? this.smoking,
      personalityPrompts: personalityPrompts ?? this.personalityPrompts,
      openingMove: openingMove ?? this.openingMove,
      createdAt: createdAt ?? this.createdAt,
      latitude: clearLatitude ? null : (latitude ?? this.latitude),
      longitude: clearLongitude ? null : (longitude ?? this.longitude),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'bio': bio,
      'photos': photos,
      'distance': distance,
      'isVerified': isVerified,
      'isPremium': isPremium,
      'interests': interests,
      'jobTitle': jobTitle,
      'company': company,
      'locationName': locationName,
      'height': height,
      'datingIntention': datingIntention,
      'education': education,
      'hometown': hometown,
      'languages': languages,
      'exercise': exercise,
      'diet': diet,
      'pets': pets,
      'sleepSchedule': sleepSchedule,
      'communicationStyle': communicationStyle,
      'loveLanguage': loveLanguage,
      'zodiac': zodiac,
      'familyPlans': familyPlans,
      'politics': politics,
      'religion': religion,
      'drinking': drinking,
      'smoking': smoking,
      'personalityPrompts': personalityPrompts,
      'openingMove': openingMove,
      'createdAt': createdAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      bio: json['bio'] as String? ?? '',
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      jobTitle: json['jobTitle'] as String? ?? '',
      company: json['company'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      height: json['height'] as int?,
      datingIntention: json['datingIntention'] as String?,
      education: json['education'] as String?,
      hometown: json['hometown'] as String?,
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList(),
      exercise: json['exercise'] as String?,
      diet: json['diet'] as String?,
      pets: (json['pets'] as List<dynamic>?)?.map((e) => e as String).toList(),
      sleepSchedule: json['sleepSchedule'] as String?,
      communicationStyle: json['communicationStyle'] as String?,
      loveLanguage: json['loveLanguage'] as String?,
      zodiac: json['zodiac'] as String?,
      familyPlans: json['familyPlans'] as String?,
      politics: json['politics'] as String?,
      religion: json['religion'] as String?,
      drinking: json['drinking'] as String?,
      smoking: json['smoking'] as String?,
      personalityPrompts: (json['personalityPrompts'] as Map<dynamic, dynamic>?)?.map(
        (k, v) => MapEntry(k as String, v as String),
      ),
      openingMove: (json['openingMove'] as Map<dynamic, dynamic>?)?.map(
        (k, v) => MapEntry(k as String, v as String),
      ),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
