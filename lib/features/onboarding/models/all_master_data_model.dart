class AllMasterData {
  String? status;
  String? message;
  Data? data;

  AllMasterData({this.status, this.message, this.data});

  AllMasterData.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['status'] = status;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class Data {
  List<Genders>? genders;
  List<ShowMe>? showMe;
  List<RelationshipGoals>? relationshipGoals;
  List<MasterItem>? languages;
  List<EducationLevels>? educationLevels;
  List<SmokingHabits>? smokingHabits;
  List<DrinkingHabits>? drinkingHabits;
  List<FitnessLevels>? fitnessLevels;
  List<SleepSchedules>? sleepSchedules;
  List<DietaryPreferences>? dietaryPreferences;
  List<FamilyPlans>? familyPlans;
  List<PetPreferences>? petPreferences;
  List<CommunicationStyles>? communicationStyles;
  List<LoveLanguages>? loveLanguages;
  List<Religions>? religions;
  List<PoliticalViews>? politicalViews;
  List<MasterItem>? interests;
  List<MasterItem>? profilePrompts;
  List<OpeningMoves>? openingMoves;
  List<MasterItem>? countries;
  List<MasterItem>? states;
  List<MasterItem>? cities;
  List<ZodiacSigns>? zodiacSigns;
  HeightRange? heightRange;
  AgeRange? ageRange;

  Data({
    this.genders,
    this.showMe,
    this.relationshipGoals,
    this.languages,
    this.educationLevels,
    this.smokingHabits,
    this.drinkingHabits,
    this.fitnessLevels,
    this.sleepSchedules,
    this.dietaryPreferences,
    this.familyPlans,
    this.petPreferences,
    this.communicationStyles,
    this.loveLanguages,
    this.religions,
    this.politicalViews,
    this.interests,
    this.profilePrompts,
    this.openingMoves,
    this.countries,
    this.states,
    this.cities,
    this.zodiacSigns,
    this.heightRange,
    this.ageRange,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['genders'] != null && json['genders'] is List) {
      genders = <Genders>[];
      for (var v in (json['genders'] as List)) {
        if (v is Map<String, dynamic>) {
          genders!.add(Genders.fromJson(v));
        }
      }
    }
    if (json['show_me'] != null && json['show_me'] is List) {
      showMe = <ShowMe>[];
      for (var v in (json['show_me'] as List)) {
        if (v is Map<String, dynamic>) {
          showMe!.add(ShowMe.fromJson(v));
        }
      }
    }
    if (json['relationship_goals'] != null &&
        json['relationship_goals'] is List) {
      relationshipGoals = <RelationshipGoals>[];
      for (var v in (json['relationship_goals'] as List)) {
        if (v is Map<String, dynamic>) {
          relationshipGoals!.add(RelationshipGoals.fromJson(v));
        }
      }
    }
    if (json['languages'] != null && json['languages'] is List) {
      languages = <MasterItem>[];
      for (var v in (json['languages'] as List)) {
        if (v is Map<String, dynamic>) {
          languages!.add(MasterItem.fromJson(v));
        }
      }
    }
    if (json['education_levels'] != null && json['education_levels'] is List) {
      educationLevels = <EducationLevels>[];
      for (var v in (json['education_levels'] as List)) {
        if (v is Map<String, dynamic>) {
          educationLevels!.add(EducationLevels.fromJson(v));
        }
      }
    }
    if (json['smoking_habits'] != null && json['smoking_habits'] is List) {
      smokingHabits = <SmokingHabits>[];
      for (var v in (json['smoking_habits'] as List)) {
        if (v is Map<String, dynamic>) {
          smokingHabits!.add(SmokingHabits.fromJson(v));
        }
      }
    }
    if (json['drinking_habits'] != null && json['drinking_habits'] is List) {
      drinkingHabits = <DrinkingHabits>[];
      for (var v in (json['drinking_habits'] as List)) {
        if (v is Map<String, dynamic>) {
          drinkingHabits!.add(DrinkingHabits.fromJson(v));
        }
      }
    }
    if (json['fitness_levels'] != null && json['fitness_levels'] is List) {
      fitnessLevels = <FitnessLevels>[];
      for (var v in (json['fitness_levels'] as List)) {
        if (v is Map<String, dynamic>) {
          fitnessLevels!.add(FitnessLevels.fromJson(v));
        }
      }
    }
    if (json['sleep_schedules'] != null && json['sleep_schedules'] is List) {
      sleepSchedules = <SleepSchedules>[];
      for (var v in (json['sleep_schedules'] as List)) {
        if (v is Map<String, dynamic>) {
          sleepSchedules!.add(SleepSchedules.fromJson(v));
        }
      }
    }
    if (json['dietary_preferences'] != null &&
        json['dietary_preferences'] is List) {
      dietaryPreferences = <DietaryPreferences>[];
      for (var v in (json['dietary_preferences'] as List)) {
        if (v is Map<String, dynamic>) {
          dietaryPreferences!.add(DietaryPreferences.fromJson(v));
        }
      }
    }
    if (json['family_plans'] != null && json['family_plans'] is List) {
      familyPlans = <FamilyPlans>[];
      for (var v in (json['family_plans'] as List)) {
        if (v is Map<String, dynamic>) {
          familyPlans!.add(FamilyPlans.fromJson(v));
        }
      }
    }
    if (json['pet_preferences'] != null && json['pet_preferences'] is List) {
      petPreferences = <PetPreferences>[];
      for (var v in (json['pet_preferences'] as List)) {
        if (v is Map<String, dynamic>) {
          petPreferences!.add(PetPreferences.fromJson(v));
        }
      }
    }
    if (json['communication_styles'] != null &&
        json['communication_styles'] is List) {
      communicationStyles = <CommunicationStyles>[];
      for (var v in (json['communication_styles'] as List)) {
        if (v is Map<String, dynamic>) {
          communicationStyles!.add(CommunicationStyles.fromJson(v));
        }
      }
    }
    if (json['love_languages'] != null && json['love_languages'] is List) {
      loveLanguages = <LoveLanguages>[];
      for (var v in (json['love_languages'] as List)) {
        if (v is Map<String, dynamic>) {
          loveLanguages!.add(LoveLanguages.fromJson(v));
        }
      }
    }
    if (json['religions'] != null && json['religions'] is List) {
      religions = <Religions>[];
      for (var v in (json['religions'] as List)) {
        if (v is Map<String, dynamic>) {
          religions!.add(Religions.fromJson(v));
        }
      }
    }
    if (json['political_views'] != null && json['political_views'] is List) {
      politicalViews = <PoliticalViews>[];
      for (var v in (json['political_views'] as List)) {
        if (v is Map<String, dynamic>) {
          politicalViews!.add(PoliticalViews.fromJson(v));
        }
      }
    }
    if (json['interests'] != null && json['interests'] is List) {
      interests = <MasterItem>[];
      for (var v in (json['interests'] as List)) {
        if (v is Map<String, dynamic>) {
          interests!.add(MasterItem.fromJson(v));
        }
      }
    }
    if (json['profile_prompts'] != null && json['profile_prompts'] is List) {
      profilePrompts = <MasterItem>[];
      for (var v in (json['profile_prompts'] as List)) {
        if (v is Map<String, dynamic>) {
          profilePrompts!.add(MasterItem.fromJson(v));
        }
      }
    }
    if (json['opening_moves'] != null && json['opening_moves'] is List) {
      openingMoves = <OpeningMoves>[];
      for (var v in (json['opening_moves'] as List)) {
        if (v is Map<String, dynamic>) {
          openingMoves!.add(OpeningMoves.fromJson(v));
        }
      }
    }
    if (json['countries'] != null && json['countries'] is List) {
      countries = <MasterItem>[];
      for (var v in (json['countries'] as List)) {
        if (v is Map<String, dynamic>) {
          countries!.add(MasterItem.fromJson(v));
        }
      }
    }
    if (json['states'] != null && json['states'] is List) {
      states = <MasterItem>[];
      for (var v in (json['states'] as List)) {
        if (v is Map<String, dynamic>) {
          states!.add(MasterItem.fromJson(v));
        }
      }
    }
    if (json['cities'] != null && json['cities'] is List) {
      cities = <MasterItem>[];
      for (var v in (json['cities'] as List)) {
        if (v is Map<String, dynamic>) {
          cities!.add(MasterItem.fromJson(v));
        }
      }
    }
    if (json['zodiac_signs'] != null && json['zodiac_signs'] is List) {
      zodiacSigns = <ZodiacSigns>[];
      for (var v in (json['zodiac_signs'] as List)) {
        if (v is Map<String, dynamic>) {
          zodiacSigns!.add(ZodiacSigns.fromJson(v));
        }
      }
    }
    heightRange =
        json['height_range'] != null &&
            json['height_range'] is Map<String, dynamic>
        ? HeightRange.fromJson(json['height_range'])
        : null;
    ageRange =
        json['age_range'] != null && json['age_range'] is Map<String, dynamic>
        ? AgeRange.fromJson(json['age_range'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    if (genders != null) {
      dataMap['genders'] = genders!.map((v) => v.toJson()).toList();
    }
    if (showMe != null) {
      dataMap['show_me'] = showMe!.map((v) => v.toJson()).toList();
    }
    if (relationshipGoals != null) {
      dataMap['relationship_goals'] = relationshipGoals!
          .map((v) => v.toJson())
          .toList();
    }
    if (languages != null) {
      dataMap['languages'] = languages!.map((v) => v.toJson()).toList();
    }
    if (educationLevels != null) {
      dataMap['education_levels'] = educationLevels!
          .map((v) => v.toJson())
          .toList();
    }
    if (smokingHabits != null) {
      dataMap['smoking_habits'] = smokingHabits!
          .map((v) => v.toJson())
          .toList();
    }
    if (drinkingHabits != null) {
      dataMap['drinking_habits'] = drinkingHabits!
          .map((v) => v.toJson())
          .toList();
    }
    if (fitnessLevels != null) {
      dataMap['fitness_levels'] = fitnessLevels!
          .map((v) => v.toJson())
          .toList();
    }
    if (sleepSchedules != null) {
      dataMap['sleep_schedules'] = sleepSchedules!
          .map((v) => v.toJson())
          .toList();
    }
    if (dietaryPreferences != null) {
      dataMap['dietary_preferences'] = dietaryPreferences!
          .map((v) => v.toJson())
          .toList();
    }
    if (familyPlans != null) {
      dataMap['family_plans'] = familyPlans!.map((v) => v.toJson()).toList();
    }
    if (petPreferences != null) {
      dataMap['pet_preferences'] = petPreferences!
          .map((v) => v.toJson())
          .toList();
    }
    if (communicationStyles != null) {
      dataMap['communication_styles'] = communicationStyles!
          .map((v) => v.toJson())
          .toList();
    }
    if (loveLanguages != null) {
      dataMap['love_languages'] = loveLanguages!
          .map((v) => v.toJson())
          .toList();
    }
    if (religions != null) {
      dataMap['religions'] = religions!.map((v) => v.toJson()).toList();
    }
    if (politicalViews != null) {
      dataMap['political_views'] = politicalViews!
          .map((v) => v.toJson())
          .toList();
    }
    if (interests != null) {
      dataMap['interests'] = interests!.map((v) => v.toJson()).toList();
    }
    if (profilePrompts != null) {
      dataMap['profile_prompts'] = profilePrompts!
          .map((v) => v.toJson())
          .toList();
    }
    if (openingMoves != null) {
      dataMap['opening_moves'] = openingMoves!.map((v) => v.toJson()).toList();
    }
    if (countries != null) {
      dataMap['countries'] = countries!.map((v) => v.toJson()).toList();
    }
    if (states != null) {
      dataMap['states'] = states!.map((v) => v.toJson()).toList();
    }
    if (cities != null) {
      dataMap['cities'] = cities!.map((v) => v.toJson()).toList();
    }
    if (zodiacSigns != null) {
      dataMap['zodiac_signs'] = zodiacSigns!.map((v) => v.toJson()).toList();
    }
    if (heightRange != null) {
      dataMap['height_range'] = heightRange!.toJson();
    }
    if (ageRange != null) {
      dataMap['age_range'] = ageRange!.toJson();
    }
    return dataMap;
  }
}

/// Generic Master Data Item handling various naming conventions across master APIs
class MasterItem {
  dynamic id;
  String? name;
  String? title;
  String? label;
  String? emoji;
  String? icon;
  String? code;

  MasterItem({
    this.id,
    this.name,
    this.title,
    this.label,
    this.emoji,
    this.icon,
    this.code,
  });

  MasterItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name =
        json['name']?.toString() ??
        json['title']?.toString() ??
        json['label']?.toString() ??
        json['name'];
    title = json['title']?.toString() ?? name;
    label = json['label']?.toString() ?? name;
    emoji = json['emoji']?.toString() ?? json['icon']?.toString();
    icon = json['icon']?.toString();
    code = json['code']?.toString();
  }

  String get displayText => name ?? title ?? label ?? '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'label': label,
      'emoji': emoji,
      'icon': icon,
      'code': code,
    };
  }
}

class Genders extends MasterItem {
  Genders({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  Genders.fromJson(super.json) : super.fromJson();
}

class ShowMe extends MasterItem {
  ShowMe({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  ShowMe.fromJson(super.json) : super.fromJson();
}

class RelationshipGoals extends MasterItem {
  RelationshipGoals({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  RelationshipGoals.fromJson(super.json) : super.fromJson();
}

class EducationLevels extends MasterItem {
  EducationLevels({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  EducationLevels.fromJson(super.json) : super.fromJson();
}

class SmokingHabits extends MasterItem {
  SmokingHabits({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  SmokingHabits.fromJson(super.json) : super.fromJson();
}

class DrinkingHabits extends MasterItem {
  DrinkingHabits({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  DrinkingHabits.fromJson(super.json) : super.fromJson();
}

class FitnessLevels extends MasterItem {
  FitnessLevels({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  FitnessLevels.fromJson(super.json) : super.fromJson();
}

class SleepSchedules extends MasterItem {
  SleepSchedules({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  SleepSchedules.fromJson(super.json) : super.fromJson();
}

class DietaryPreferences extends MasterItem {
  DietaryPreferences({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  DietaryPreferences.fromJson(super.json) : super.fromJson();
}

class FamilyPlans extends MasterItem {
  FamilyPlans({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  FamilyPlans.fromJson(super.json) : super.fromJson();
}

class PetPreferences extends MasterItem {
  PetPreferences({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  PetPreferences.fromJson(super.json) : super.fromJson();
}

class CommunicationStyles extends MasterItem {
  CommunicationStyles({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  CommunicationStyles.fromJson(super.json) : super.fromJson();
}

class LoveLanguages extends MasterItem {
  LoveLanguages({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  LoveLanguages.fromJson(super.json) : super.fromJson();
}

class Religions extends MasterItem {
  Religions({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  Religions.fromJson(super.json) : super.fromJson();
}

class PoliticalViews extends MasterItem {
  PoliticalViews({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
  });
  PoliticalViews.fromJson(super.json) : super.fromJson();
}

class OpeningMoves extends MasterItem {
  String? question;

  OpeningMoves({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
    this.question,
  });

  OpeningMoves.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    question =
        json['question']?.toString() ??
        json['name']?.toString() ??
        json['title']?.toString();
  }

  @override
  String get displayText => question ?? super.displayText;

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['question'] = question;
    return map;
  }
}

class ZodiacSigns extends MasterItem {
  String? sign;
  String? symbol;

  ZodiacSigns({
    super.id,
    super.name,
    super.title,
    super.label,
    super.emoji,
    super.icon,
    super.code,
    this.sign,
    this.symbol,
  });

  ZodiacSigns.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    sign = json['sign']?.toString();
    symbol = json['symbol']?.toString() ?? json['emoji']?.toString();
  }

  @override
  String get displayText {
    final baseName = name ?? title ?? sign ?? '';
    if (symbol != null && symbol!.isNotEmpty) {
      return '$baseName $symbol';
    }
    return baseName;
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['sign'] = sign;
    map['symbol'] = symbol;
    return map;
  }
}

class HeightRange {
  int? min;
  int? max;
  int? step;

  HeightRange({this.min, this.max, this.step});

  HeightRange.fromJson(Map<String, dynamic> json) {
    min = json['min'] is int
        ? json['min']
        : int.tryParse(json['min']?.toString() ?? '');
    max = json['max'] is int
        ? json['max']
        : int.tryParse(json['max']?.toString() ?? '');
    step = json['step'] is int
        ? json['step']
        : int.tryParse(json['step']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['min'] = min;
    data['max'] = max;
    data['step'] = step;
    return data;
  }
}

class AgeRange {
  int? min;
  int? max;

  AgeRange({this.min, this.max});

  AgeRange.fromJson(Map<String, dynamic> json) {
    min = json['min'] is int
        ? json['min']
        : int.tryParse(json['min']?.toString() ?? '');
    max = json['max'] is int
        ? json['max']
        : int.tryParse(json['max']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['min'] = min;
    data['max'] = max;
    return data;
  }
}
