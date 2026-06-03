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
  List<MealPlan> _sharedPlans = [];
  List<MealPlan> _likedPlans = [];
  Set<String> _likedPlanIds = {};
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  double _generationProgress = 0.0;

  // Getters
  List<MealPlan> get mealPlans => _mealPlans;
  MealPlan? get currentPlan => _currentPlan;
  List<MealPlan> get sharedPlans => _sharedPlans;
  List<MealPlan> get likedPlans => _likedPlans;
  Set<String> get likedPlanIds => _likedPlanIds;
  bool isLiked(String planId) => _likedPlanIds.contains(planId);
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
          .limit(20)
          .get();

      _mealPlans = snapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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

      // 로컬 상태 업데이트 헬퍼
      List<DailyMealPlan> _updateDailyPlans(List<DailyMealPlan> dailyPlans) {
        return dailyPlans.map((daily) {
          if (daily.date.year == date.year &&
              daily.date.month == date.month &&
              daily.date.day == date.day) {
            final updatedMeals = daily.meals
                .map((meal) => meal.type == mealType ? newMeal : meal)
                .toList();
            return DailyMealPlan(date: daily.date, meals: updatedMeals);
          }
          return daily;
        }).toList();
      }

      // currentPlan 업데이트
      if (_currentPlan != null && _currentPlan!.id == planId) {
        final updatedDailyPlans = _updateDailyPlans(_currentPlan!.dailyPlans);
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

      // mealPlans 리스트도 업데이트
      _mealPlans = _mealPlans.map((p) {
        if (p.id != planId) return p;
        return p.copyWith(
          dailyPlans: _updateDailyPlans(p.dailyPlans),
          updatedAt: DateTime.now(),
        );
      }).toList();

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
    // currentPlan에서 먼저 확인
    if (_currentPlan?.id == planId) return _currentPlan;

    // 로컬에서 찾기
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

  /// 공유된 식단 목록 로드 (커뮤니티)
  Future<void> loadSharedMealPlans() async {
    try {
      final snapshot = await _firestore
          .collection('sharedMealPlans')
          .limit(30)
          .get();
      _sharedPlans = snapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.likes.compareTo(a.likes));
      notifyListeners();
    } catch (e) {
      debugPrint('공유 식단 로드 실패: $e');
    }
  }

  /// 식단 공유
  Future<bool> shareMealPlan(String planId, {String? authorName, String? dietGoalName}) async {
    try {
      final plan = await getMealPlan(planId);
      if (plan == null) return false;

      final data = plan.toFirestore();
      if (authorName != null) data['authorName'] = authorName;
      if (dietGoalName != null) data['dietGoalName'] = dietGoalName;

      await _firestore.collection('sharedMealPlans').doc(planId).set(data);
      await _firestore.collection('mealPlans').doc(planId).update({'isShared': true});

      _currentPlan = _currentPlan?.id == planId ? _currentPlan!.copyWith(isShared: true) : _currentPlan;
      _mealPlans = _mealPlans.map((p) => p.id == planId ? p.copyWith(isShared: true) : p).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '공유 실패: $e';
      notifyListeners();
      return false;
    }
  }

  /// 식단 공유 취소
  Future<bool> unshareMealPlan(String planId) async {
    try {
      await _firestore.collection('sharedMealPlans').doc(planId).delete();
      await _firestore.collection('mealPlans').doc(planId).update({'isShared': false});

      _currentPlan = _currentPlan?.id == planId ? _currentPlan!.copyWith(isShared: false) : _currentPlan;
      _mealPlans = _mealPlans.map((p) => p.id == planId ? p.copyWith(isShared: false) : p).toList();
      _sharedPlans.removeWhere((p) => p.id == planId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '공유 취소 실패: $e';
      notifyListeners();
      return false;
    }
  }

  /// 사용자의 좋아요 ID 목록 로드
  Future<void> loadLikedPlanIds(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (data != null && data['likedPlanIds'] != null) {
        _likedPlanIds = Set<String>.from(data['likedPlanIds'] as List);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('좋아요 목록 로드 실패: $e');
    }
  }

  /// 사용자가 좋아요한 공유 식단 목록 로드
  Future<void> loadLikedPlans(String userId) async {
    if (_likedPlanIds.isEmpty) {
      await loadLikedPlanIds(userId);
    }
    if (_likedPlanIds.isEmpty) {
      _likedPlans = [];
      notifyListeners();
      return;
    }
    try {
      // Firestore in 쿼리는 최대 30개
      final ids = _likedPlanIds.take(30).toList();
      final snapshot = await _firestore
          .collection('sharedMealPlans')
          .where(FieldPath.documentId, whereIn: ids)
          .get();
      _likedPlans = snapshot.docs.map((d) => MealPlan.fromFirestore(d)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('좋아요 식단 로드 실패: $e');
    }
  }

  /// 공유 식단 좋아요 토글
  Future<void> toggleLike(String planId, String userId) async {
    final alreadyLiked = _likedPlanIds.contains(planId);
    try {
      if (alreadyLiked) {
        // 좋아요 취소
        _likedPlanIds.remove(planId);
        _likedPlans.removeWhere((p) => p.id == planId);
        await _firestore.collection('sharedMealPlans').doc(planId).update({
          'likes': FieldValue.increment(-1),
        });
        await _firestore.collection('users').doc(userId).update({
          'likedPlanIds': FieldValue.arrayRemove([planId]),
        });
        _sharedPlans = _sharedPlans
            .map((p) => p.id == planId ? p.copyWith(likes: (p.likes - 1).clamp(0, 99999)) : p)
            .toList();
      } else {
        // 좋아요 추가
        _likedPlanIds.add(planId);
        await _firestore.collection('sharedMealPlans').doc(planId).update({
          'likes': FieldValue.increment(1),
        });
        await _firestore.collection('users').doc(userId).set({
          'likedPlanIds': FieldValue.arrayUnion([planId]),
        }, SetOptions(merge: true));
        _sharedPlans = _sharedPlans
            .map((p) => p.id == planId ? p.copyWith(likes: p.likes + 1) : p)
            .toList();
        // 좋아요한 식단 목록에 추가
        final liked = _sharedPlans.firstWhere(
          (p) => p.id == planId,
          orElse: () => _likedPlans.firstWhere((p) => p.id == planId,
              orElse: () => _sharedPlans.first),
        );
        if (!_likedPlans.any((p) => p.id == planId)) {
          _likedPlans.insert(0, liked);
        }
      }
      notifyListeners();
    } catch (e) {
      // 실패 시 롤백
      if (alreadyLiked) {
        _likedPlanIds.add(planId);
      } else {
        _likedPlanIds.remove(planId);
      }
      debugPrint('좋아요 처리 실패: $e');
      notifyListeners();
    }
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
