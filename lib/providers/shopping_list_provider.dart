import 'package:flutter/foundation.dart';
import '../models/meal_plan.dart';

class ShoppingListProvider extends ChangeNotifier {
  List<Ingredient> _ingredients = [];
  Map<String, bool> _purchasedStatus = {};
  bool _isLoading = false;

  // Getters
  List<Ingredient> get ingredients => _ingredients;
  List<Ingredient> get pendingIngredients =>
      _ingredients.where((i) => !_purchasedStatus[i.id]!).toList();
  List<Ingredient> get purchasedIngredients =>
      _ingredients.where((i) => _purchasedStatus[i.id]!).toList();
  bool get isLoading => _isLoading;

  /// 카테고리별 재료 가져오기
  Map<String, List<Ingredient>> get ingredientsByCategory {
    final result = <String, List<Ingredient>>{};
    for (final ingredient in _ingredients) {
      if (!result.containsKey(ingredient.category)) {
        result[ingredient.category] = [];
      }
      result[ingredient.category]!.add(ingredient);
    }
    return result;
  }

  /// 전체 진행률 (구매 완료 비율)
  double get progress {
    if (_ingredients.isEmpty) return 0.0;
    return purchasedIngredients.length / _ingredients.length;
  }

  /// 식단에서 장보기 리스트 로드
  void loadFromMealPlan(MealPlan mealPlan) {
    _isLoading = true;
    notifyListeners();

    // 재료 합산 처리
    final ingredientMap = <String, Ingredient>{};

    for (final ingredient in mealPlan.ingredients) {
      final key = '${ingredient.name}_${ingredient.unit}';
      if (ingredientMap.containsKey(key)) {
        // 같은 재료가 있으면 수량 합산
        final existing = ingredientMap[key]!;
        ingredientMap[key] = existing.copyWith(
          quantity: existing.quantity + ingredient.quantity,
        );
      } else {
        ingredientMap[key] = ingredient;
      }
    }

    _ingredients = ingredientMap.values.toList();

    // 구매 상태 초기화
    _purchasedStatus = {
      for (final ingredient in _ingredients) ingredient.id: ingredient.isPurchased
    };

    // 카테고리 순으로 정렬
    _ingredients.sort((a, b) {
      final categoryOrder = Ingredient.categories.indexOf(a.category)
          .compareTo(Ingredient.categories.indexOf(b.category));
      if (categoryOrder != 0) return categoryOrder;
      return a.name.compareTo(b.name);
    });

    _isLoading = false;
    notifyListeners();
  }

  /// 구매 상태 토글
  void togglePurchased(String ingredientId) {
    if (_purchasedStatus.containsKey(ingredientId)) {
      _purchasedStatus[ingredientId] = !_purchasedStatus[ingredientId]!;
      notifyListeners();
    }
  }

  /// 모든 재료 구매 완료 처리
  void markAllPurchased() {
    for (final id in _purchasedStatus.keys) {
      _purchasedStatus[id] = true;
    }
    notifyListeners();
  }

  /// 모든 재료 구매 미완료 처리
  void clearAllPurchased() {
    for (final id in _purchasedStatus.keys) {
      _purchasedStatus[id] = false;
    }
    notifyListeners();
  }

  /// 구매 상태 확인
  bool isPurchased(String ingredientId) {
    return _purchasedStatus[ingredientId] ?? false;
  }

  /// 공유용 텍스트 생성
  String toShareText() {
    final buffer = StringBuffer();
    buffer.writeln('🛒 장보기 리스트');
    buffer.writeln('');

    for (final category in Ingredient.categories) {
      final categoryIngredients = _ingredients
          .where((i) => i.category == category)
          .toList();

      if (categoryIngredients.isEmpty) continue;

      buffer.writeln('[$category]');
      for (final ingredient in categoryIngredients) {
        final checkbox = isPurchased(ingredient.id) ? '✅' : '⬜';
        buffer.writeln('$checkbox ${ingredient.name} ${ingredient.quantityDisplay}');
      }
      buffer.writeln('');
    }

    buffer.writeln('---');
    buffer.writeln('AI Meal Planner에서 생성됨');

    return buffer.toString();
  }

  /// 리스트 초기화
  void clear() {
    _ingredients = [];
    _purchasedStatus = {};
    notifyListeners();
  }
}
