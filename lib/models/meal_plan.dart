import 'package:cloud_firestore/cloud_firestore.dart';

/// 끼니 유형
enum MealType {
  breakfast,  // 아침
  lunch,      // 점심
  dinner,     // 저녁
  snack,      // 간식
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return '아침';
      case MealType.lunch:
        return '점심';
      case MealType.dinner:
        return '저녁';
      case MealType.snack:
        return '간식';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}

/// 영양 정보 모델
class NutritionInfo {
  final int calories;
  final double carbohydrates;  // 탄수화물 (g)
  final double protein;        // 단백질 (g)
  final double fat;            // 지방 (g)
  final double? fiber;         // 식이섬유 (g)
  final double? sodium;        // 나트륨 (mg)

  NutritionInfo({
    required this.calories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    this.fiber,
    this.sodium,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'] ?? 0,
      carbohydrates: (json['carbohydrates'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: json['fiber']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'carbohydrates': carbohydrates,
      'protein': protein,
      'fat': fat,
      'fiber': fiber,
      'sodium': sodium,
    };
  }

  /// 총 칼로리 대비 영양소 비율 (%)
  double get carbPercent => carbohydrates * 4 / calories * 100;
  double get proteinPercent => protein * 4 / calories * 100;
  double get fatPercent => fat * 9 / calories * 100;
}

/// 개별 식사 모델
class Meal {
  final String id;
  final String name;
  final MealType type;
  final String? description;
  final NutritionInfo nutrition;
  final List<String> ingredients;
  final String? recipe;
  final String? imageUrl;
  final int? cookingTime;  // 조리 시간 (분)
  final int? rating;       // 사용자 평가 (1-5)
  final bool isLiked;      // 좋아요 여부

  Meal({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.nutrition,
    required this.ingredients,
    this.recipe,
    this.imageUrl,
    this.cookingTime,
    this.rating,
    this.isLiked = false,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      type: MealType.values[json['type'] ?? 0],
      description: json['description'],
      nutrition: NutritionInfo.fromJson(json['nutrition'] ?? {}),
      ingredients: List<String>.from(json['ingredients'] ?? []),
      recipe: json['recipe'],
      imageUrl: json['imageUrl'],
      cookingTime: json['cookingTime'],
      rating: json['rating'],
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'description': description,
      'nutrition': nutrition.toJson(),
      'ingredients': ingredients,
      'recipe': recipe,
      'imageUrl': imageUrl,
      'cookingTime': cookingTime,
      'rating': rating,
      'isLiked': isLiked,
    };
  }

  Meal copyWith({
    String? id,
    String? name,
    MealType? type,
    String? description,
    NutritionInfo? nutrition,
    List<String>? ingredients,
    String? recipe,
    String? imageUrl,
    int? cookingTime,
    int? rating,
    bool? isLiked,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      nutrition: nutrition ?? this.nutrition,
      ingredients: ingredients ?? this.ingredients,
      recipe: recipe ?? this.recipe,
      imageUrl: imageUrl ?? this.imageUrl,
      cookingTime: cookingTime ?? this.cookingTime,
      rating: rating ?? this.rating,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

/// 하루 식단 모델
class DailyMealPlan {
  final DateTime date;
  final List<Meal> meals;
  final NutritionInfo totalNutrition;

  DailyMealPlan({
    required this.date,
    required this.meals,
    NutritionInfo? totalNutrition,
  }) : totalNutrition = totalNutrition ?? _calculateTotalNutrition(meals);

  static NutritionInfo _calculateTotalNutrition(List<Meal> meals) {
    int totalCalories = 0;
    double totalCarbs = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (final meal in meals) {
      totalCalories += meal.nutrition.calories;
      totalCarbs += meal.nutrition.carbohydrates;
      totalProtein += meal.nutrition.protein;
      totalFat += meal.nutrition.fat;
    }

    return NutritionInfo(
      calories: totalCalories,
      carbohydrates: totalCarbs,
      protein: totalProtein,
      fat: totalFat,
    );
  }

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      date: DateTime.parse(json['date']),
      meals: (json['meals'] as List)
          .map((m) => Meal.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'totalNutrition': totalNutrition.toJson(),
    };
  }

  /// 특정 끼니 가져오기
  Meal? getMealByType(MealType type) {
    try {
      return meals.firstWhere((m) => m.type == type);
    } catch (_) {
      return null;
    }
  }
}

/// 식단 계획 모델 (전체)
class MealPlan {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyMealPlan> dailyPlans;
  final List<Ingredient> ingredients;
  final bool isShared;
  final int likes;
  final DateTime createdAt;
  final DateTime updatedAt;
  // 커뮤니티 공유 시 추가 필드
  final String? authorName;
  final String? dietGoalName;

  MealPlan({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.dailyPlans,
    required this.ingredients,
    this.isShared = false,
    this.likes = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.authorName,
    this.dietGoalName,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 총 기간 (일수)
  int get durationDays => endDate.difference(startDate).inDays + 1;

  /// 총 영양 정보 평균
  NutritionInfo get averageNutrition {
    if (dailyPlans.isEmpty) {
      return NutritionInfo(
        calories: 0,
        carbohydrates: 0,
        protein: 0,
        fat: 0,
      );
    }

    int totalCalories = 0;
    double totalCarbs = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (final plan in dailyPlans) {
      totalCalories += plan.totalNutrition.calories;
      totalCarbs += plan.totalNutrition.carbohydrates;
      totalProtein += plan.totalNutrition.protein;
      totalFat += plan.totalNutrition.fat;
    }

    final count = dailyPlans.length;
    return NutritionInfo(
      calories: (totalCalories / count).round(),
      carbohydrates: totalCarbs / count,
      protein: totalProtein / count,
      fat: totalFat / count,
    );
  }

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      id: doc.id,
      userId: data['userId'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      dailyPlans: (data['dailyPlans'] as List)
          .map((d) => DailyMealPlan.fromJson(d))
          .toList(),
      ingredients: (data['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      isShared: data['isShared'] ?? false,
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      authorName: data['authorName'] as String?,
      dietGoalName: data['dietGoalName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'dailyPlans': dailyPlans.map((d) => d.toJson()).toList(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'isShared': isShared,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      if (authorName != null) 'authorName': authorName,
      if (dietGoalName != null) 'dietGoalName': dietGoalName,
    };
  }

  MealPlan copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    List<DailyMealPlan>? dailyPlans,
    List<Ingredient>? ingredients,
    bool? isShared,
    int? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? dietGoalName,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      ingredients: ingredients ?? this.ingredients,
      isShared: isShared ?? this.isShared,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      dietGoalName: dietGoalName ?? this.dietGoalName,
    );
  }
}

/// 재료 모델
class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final bool isPurchased;
  final String? coupangKeyword;  // 쿠팡 검색 키워드

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.isPurchased = false,
    this.coupangKeyword,
  });

  /// 카테고리 목록
  static const List<String> categories = [
    '채소',
    '과일',
    '육류',
    '해산물',
    '유제품',
    '곡류',
    '조미료',
    '기타',
  ];

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '개',
      category: json['category'] ?? '기타',
      isPurchased: json['isPurchased'] ?? false,
      coupangKeyword: json['coupangKeyword'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'isPurchased': isPurchased,
      'coupangKeyword': coupangKeyword,
    };
  }

  Ingredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    bool? isPurchased,
    String? coupangKeyword,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isPurchased: isPurchased ?? this.isPurchased,
      coupangKeyword: coupangKeyword ?? this.coupangKeyword,
    );
  }

  /// 수량 표시 문자열
  String get quantityDisplay {
    if (quantity == quantity.roundToDouble()) {
      return '${quantity.toInt()} $unit';
    }
    return '${quantity.toStringAsFixed(1)} $unit';
  }
}
