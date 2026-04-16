import 'package:cloud_firestore/cloud_firestore.dart';

/// 식단 목적 열거형
enum DietGoal {
  weightLoss,     // 다이어트
  weightGain,     // 체중 증가
  maintain,       // 유지
  muscleGain,     // 근육 증가
  healthCare,     // 건강 관리
}

extension DietGoalExtension on DietGoal {
  String get displayName {
    switch (this) {
      case DietGoal.weightLoss:
        return '다이어트';
      case DietGoal.weightGain:
        return '체중 증가';
      case DietGoal.maintain:
        return '체중 유지';
      case DietGoal.muscleGain:
        return '근육 증가';
      case DietGoal.healthCare:
        return '건강 관리';
    }
  }
  
  String get description {
    switch (this) {
      case DietGoal.weightLoss:
        return '건강하게 체중을 줄이고 싶어요';
      case DietGoal.weightGain:
        return '건강하게 체중을 늘리고 싶어요';
      case DietGoal.maintain:
        return '현재 체중을 유지하고 싶어요';
      case DietGoal.muscleGain:
        return '근육량을 늘리고 싶어요';
      case DietGoal.healthCare:
        return '전반적인 건강을 관리하고 싶어요';
    }
  }

  String get icon {
    switch (this) {
      case DietGoal.weightLoss:
        return '⚖️';
      case DietGoal.weightGain:
        return '📈';
      case DietGoal.maintain:
        return '✨';
      case DietGoal.muscleGain:
        return '💪';
      case DietGoal.healthCare:
        return '❤️';
    }
  }
}

/// 조리 난이도 열거형
enum CookingDifficulty {
  easy,     // 간단
  medium,   // 보통
  hard,     // 복잡
}

extension CookingDifficultyExtension on CookingDifficulty {
  String get displayName {
    switch (this) {
      case CookingDifficulty.easy:
        return '간단';
      case CookingDifficulty.medium:
        return '보통';
      case CookingDifficulty.hard:
        return '복잡';
    }
  }
  
  String get description {
    switch (this) {
      case CookingDifficulty.easy:
        return '15분 이내, 간단한 조리';
      case CookingDifficulty.medium:
        return '30분 이내, 일반적인 요리';
      case CookingDifficulty.hard:
        return '시간과 정성이 필요한 요리';
    }
  }
}

/// 알러지 유형
class AllergyType {
  static const List<String> commonAllergies = [
    '계란',
    '우유',
    '밀',
    '대두',
    '땅콩',
    '견과류',
    '갑각류',
    '조개류',
    '생선',
    '메밀',
    '복숭아',
    '토마토',
    '돼지고기',
    '소고기',
    '닭고기',
    '아황산류',
  ];
}

/// 사용자 프로필 모델
class UserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DietGoal? dietGoal;
  final List<String> allergies;
  final List<String> preferredFoods;
  final List<String> dislikedFoods;
  final int mealsPerDay;
  final int? budgetMin;
  final int? budgetMax;
  final CookingDifficulty cookingDifficulty;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.dietGoal,
    this.allergies = const [],
    this.preferredFoods = const [],
    this.dislikedFoods = const [],
    this.mealsPerDay = 3,
    this.budgetMin,
    this.budgetMax,
    this.cookingDifficulty = CookingDifficulty.medium,
    this.onboardingCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Firestore에서 가져오기
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      dietGoal: data['dietGoal'] != null
          ? DietGoal.values[data['dietGoal']]
          : null,
      allergies: List<String>.from(data['allergies'] ?? []),
      preferredFoods: List<String>.from(data['preferredFoods'] ?? []),
      dislikedFoods: List<String>.from(data['dislikedFoods'] ?? []),
      mealsPerDay: data['mealsPerDay'] ?? 3,
      budgetMin: data['budgetMin'],
      budgetMax: data['budgetMax'],
      cookingDifficulty: data['cookingDifficulty'] != null
          ? CookingDifficulty.values[data['cookingDifficulty']]
          : CookingDifficulty.medium,
      onboardingCompleted: data['onboardingCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firestore에 저장할 형태로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'dietGoal': dietGoal?.index,
      'allergies': allergies,
      'preferredFoods': preferredFoods,
      'dislikedFoods': dislikedFoods,
      'mealsPerDay': mealsPerDay,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'cookingDifficulty': cookingDifficulty.index,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// copyWith 메서드
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DietGoal? dietGoal,
    List<String>? allergies,
    List<String>? preferredFoods,
    List<String>? dislikedFoods,
    int? mealsPerDay,
    int? budgetMin,
    int? budgetMax,
    CookingDifficulty? cookingDifficulty,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      dietGoal: dietGoal ?? this.dietGoal,
      allergies: allergies ?? this.allergies,
      preferredFoods: preferredFoods ?? this.preferredFoods,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      cookingDifficulty: cookingDifficulty ?? this.cookingDifficulty,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// AI 프롬프트용 문자열 생성
  String toPromptString() {
    final buffer = StringBuffer();
    
    if (dietGoal != null) {
      buffer.writeln('목표: ${dietGoal!.displayName}');
    }
    
    if (allergies.isNotEmpty) {
      buffer.writeln('알러지: ${allergies.join(", ")}');
    }
    
    if (preferredFoods.isNotEmpty) {
      buffer.writeln('선호 음식: ${preferredFoods.join(", ")}');
    }
    
    if (dislikedFoods.isNotEmpty) {
      buffer.writeln('비선호 음식: ${dislikedFoods.join(", ")}');
    }
    
    buffer.writeln('하루 식사 횟수: $mealsPerDay회');
    buffer.writeln('조리 난이도: ${cookingDifficulty.displayName}');
    
    if (budgetMin != null || budgetMax != null) {
      buffer.writeln('예산: ${budgetMin ?? 0}원 ~ ${budgetMax ?? "무제한"}원');
    }
    
    return buffer.toString();
  }
}
