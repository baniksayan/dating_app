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
  final DateTime? createdAt;

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
    this.createdAt,
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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
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
      'createdAt': createdAt?.toIso8601String(),
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
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}
