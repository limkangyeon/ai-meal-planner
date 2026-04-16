import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import '../services/gemini_service.dart';

class MealPlanProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();

  List<MealPlan> _mealPlans = [];
  MealPlan? _currentPlan;
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  double _generationProgress = 0.0;

  // Getters
  List<MealPlan> get mealPlans => _mealPlans;
  MealPlan? get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  double get generationProgress => _generationProgress;

  /// 사용자의 식단 목록 로드
  Future<void> loadMealPlans(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      final snapshot = await _firestore
          .collection('mealPlans')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      _mealPlans = snapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList();

      if (_mealPlans.isNotEmpty && _currentPlan == null) {
        _currentPlan = _mealPlans.first;
      }
    } catch (e) {
      _error = '식단을 불러오는 데 실패했습니다: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// AI 식단 생성
  Future<MealPlan?> generateMealPlan({
    required String userId,
    required UserProfile userProfile,
    required int days,
    DateTime? startDate,
  }) async {
    _isGenerating = true;
    _generationProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      final start = startDate ?? DateTime.now();
      final end = start.add(Duration(days: days - 1));

      // 진행률 업데이트 콜백
      void onProgress(double progress) {
        _generationProgress = progress;
        notifyListeners();
      }

      // AI로 식단 생성
      final generatedData = await _geminiService.generateMealPlan(
        userProfile: userProfile,
        days: days,
        startDate: start,
        onProgress: onProgress,
      );

      if (generatedData == null) {
        _error = '식단 생성에 실패했습니다. 다시 시도해주세요.';
        return null;
      }

      // 식단 객체 생성
      final mealPlan = MealPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        startDate: start,
        endDate: end,
        dailyPlans: generatedData.dailyPlans,
        ingredients: generatedData.ingredients,
      );

      // Firestore에 저장
      final docRef = await _firestore.collection('mealPlans').add(
        mealPlan.toFirestore(),
      );

      final savedPlan = mealPlan.copyWith(id: docRef.id);

      // 로컬 상태 업데이트
      _mealPlans.insert(0, savedPlan);
      _currentPlan = savedPlan;

      return savedPlan;
    } catch (e) {
      _error = '식단 생성 중 오류가 발생했습니다: $e';
      return null;
    } finally {
      _isGenerating = false;
      _generationProgress = 0.0;
      notifyListeners();
    }
  }

  /// 특정 끼니 재생성
  Future<bool> regenerateMeal({
    required String planId,
    required DateTime date,
    required MealType mealType,
    required UserProfile userProfile,
    String? reason,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final newMeal = await _geminiService.regenerateSingleMeal(
        userProfile: userProfile,
        date: date,
        mealType: mealType,
        reason: reason,
      );

      if (newMeal == null) {
        _error = '식단 재생성에 실패했습니다';
        return false;
      }

      // 로컬 상태 업데이트
      if (_currentPlan != null && _currentPlan!.id == planId) {
        final updatedDailyPlans = _currentPlan!.dailyPlans.map((daily) {
          if (daily.date.year == date.year &&
              daily.date.month == date.month &&
              daily.date.day == date.day) {
            final updatedMeals = daily.meals.map((meal) {
              if (meal.type == mealType) {
                return newMeal;
              }
              return meal;
            }).toList();
            return DailyMealPlan(date: daily.date, meals: updatedMeals);
          }
          return daily;
        }).toList();

        _currentPlan = _currentPlan!.copyWith(
          dailyPlans: updatedDailyPlans,
          updatedAt: DateTime.now(),
        );

        // Firestore 업데이트
        await _firestore.collection('mealPlans').doc(planId).update({
          'dailyPlans': updatedDailyPlans.map((d) => d.toJson()).toList(),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      return true;
    } catch (e) {
      _error = '식단 재생성 중 오류가 발생했습니다: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 식단 평가 (좋아요/싫어요)
  Future<void> rateMeal({
    required String planId,
    required String mealId,
    required bool isLiked,
  }) async {
    try {
      if (_currentPlan != null && _currentPlan!.id == planId) {
        final updatedDailyPlans = _currentPlan!.dailyPlans.map((daily) {
          final updatedMeals = daily.meals.map((meal) {
            if (meal.id == mealId) {
              return meal.copyWith(isLiked: isLiked);
            }
            return meal;
          }).toList();
          return DailyMealPlan(date: daily.date, meals: updatedMeals);
        }).toList();

        _currentPlan = _currentPlan!.copyWith(dailyPlans: updatedDailyPlans);
        notifyListeners();

        // Firestore 업데이트
        await _firestore.collection('mealPlans').doc(planId).update({
          'dailyPlans': updatedDailyPlans.map((d) => d.toJson()).toList(),
        });
      }
    } catch (e) {
      debugPrint('평가 저장 실패: $e');
    }
  }

  /// 식단 삭제
  Future<bool> deleteMealPlan(String planId) async {
    _setLoading(true);

    try {
      await _firestore.collection('mealPlans').doc(planId).delete();

      _mealPlans.removeWhere((plan) => plan.id == planId);
      if (_currentPlan?.id == planId) {
        _currentPlan = _mealPlans.isNotEmpty ? _mealPlans.first : null;
      }

      return true;
    } catch (e) {
      _error = '식단 삭제 실패: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 현재 식단 설정
  void setCurrentPlan(MealPlan plan) {
    _currentPlan = plan;
    notifyListeners();
  }

  /// 특정 식단 가져오기
  Future<MealPlan?> getMealPlan(String planId) async {
    // 먼저 로컬에서 찾기
    final local = _mealPlans.where((p) => p.id == planId).firstOrNull;
    if (local != null) return local;

    // Firestore에서 가져오기
    try {
      final doc = await _firestore.collection('mealPlans').doc(planId).get();
      if (doc.exists) {
        return MealPlan.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('식단 조회 실패: $e');
    }
    return null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
