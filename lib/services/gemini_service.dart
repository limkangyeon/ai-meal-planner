import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/meal_plan.dart';
import '../models/user_profile.dart';

/// Gemini AI 응답 데이터
class GeneratedMealData {
  final List<DailyMealPlan> dailyPlans;
  final List<Ingredient> ingredients;

  GeneratedMealData({
    required this.dailyPlans,
    required this.ingredients,
  });
}

/// Gemini AI 서비스
class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.5-flash-lite';
  
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// 식단 생성 메인 메서드
  Future<GeneratedMealData?> generateMealPlan({
    required UserProfile userProfile,
    required int days,
    required DateTime startDate,
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      final prompt = _buildMealPlanPrompt(userProfile, days, startDate);
      
      onProgress?.call(0.2);

      final response = await _callGeminiAPI(prompt);
      
      onProgress?.call(0.7);

      if (response == null) return null;

      final parsedData = _parseMealPlanResponse(response, days, startDate);
      
      onProgress?.call(1.0);

      return parsedData;
    } catch (e) {
      debugPrint('식단 생성 오류: $e');
      return null;
    }
  }

  /// 단일 끼니 재생성
  Future<Meal?> regenerateSingleMeal({
    required UserProfile userProfile,
    required DateTime date,
    required MealType mealType,
    String? reason,
  }) async {
    try {
      final prompt = _buildRegenerateMealPrompt(
        userProfile,
        date,
        mealType,
        reason,
      );

      final response = await _callGeminiAPI(prompt);
      if (response == null) return null;

      return _parseSingleMealResponse(response, mealType);
    } catch (e) {
      debugPrint('식단 재생성 오류: $e');
      return null;
    }
  }

  /// Gemini API 호출
  Future<String?> _callGeminiAPI(String prompt) async {
    if (_apiKey.isEmpty) {
      debugPrint('Gemini API 키가 설정되지 않았습니다');
      return null;
    }

    final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 8192,
            'responseMimeType': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        debugPrint('API 오류: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('API 호출 실패: $e');
      return null;
    }
  }

  /// 식단 생성 프롬프트 구성
  String _buildMealPlanPrompt(
    UserProfile userProfile,
    int days,
    DateTime startDate,
  ) {
    final userInfo = userProfile.toPromptString();
    final mealTypes = _getMealTypesForCount(userProfile.mealsPerDay);

    return '''
당신은 전문 영양사입니다. 다음 사용자 정보를 바탕으로 ${days}일간의 맞춤형 식단을 생성해주세요.

## 사용자 정보
$userInfo

## 요구사항
1. ${days}일간의 식단 (시작일: ${_formatDate(startDate)})
2. 하루 ${userProfile.mealsPerDay}끼 식사 (${mealTypes.map((t) => t.displayName).join(', ')})
3. 한국인 식단 위주로 구성
4. 영양 균형을 고려한 메뉴 선정
5. 알러지 재료는 절대 포함하지 않음
6. 비선호 음식은 가능한 제외
7. 선호 음식은 적절히 포함

## 출력 형식 (JSON)
다음 형식으로 정확히 출력해주세요:
{
  "dailyPlans": [
    {
      "date": "YYYY-MM-DD",
      "meals": [
        {
          "id": "unique_id",
          "name": "음식 이름",
          "type": 0,  // 0: 아침, 1: 점심, 2: 저녁, 3: 간식
          "description": "간단한 설명",
          "nutrition": {
            "calories": 500,
            "carbohydrates": 60,
            "protein": 25,
            "fat": 15
          },
          "ingredients": ["재료1", "재료2"],
          "recipe": "간단한 조리법",
          "cookingTime": 20
        }
      ]
    }
  ],
  "ingredients": [
    {
      "id": "unique_id",
      "name": "재료명",
      "quantity": 2,
      "unit": "개",
      "category": "채소"  // 채소, 과일, 육류, 해산물, 유제품, 곡류, 조미료, 기타
    }
  ]
}

중복 재료는 합산하여 한 번만 표시해주세요.
''';
  }

  /// 끼니 재생성 프롬프트
  String _buildRegenerateMealPrompt(
    UserProfile userProfile,
    DateTime date,
    MealType mealType,
    String? reason,
  ) {
    final userInfo = userProfile.toPromptString();

    return '''
당신은 전문 영양사입니다. 다음 사용자의 ${mealType.displayName} 메뉴를 새로 추천해주세요.

## 사용자 정보
$userInfo

## 날짜
${_formatDate(date)}

${reason != null ? '## 재생성 이유\n$reason\n' : ''}

## 출력 형식 (JSON)
{
  "id": "unique_id",
  "name": "음식 이름",
  "type": ${mealType.index},
  "description": "간단한 설명",
  "nutrition": {
    "calories": 500,
    "carbohydrates": 60,
    "protein": 25,
    "fat": 15
  },
  "ingredients": ["재료1", "재료2"],
  "recipe": "간단한 조리법",
  "cookingTime": 20
}
''';
  }

  /// 식단 응답 파싱
  GeneratedMealData? _parseMealPlanResponse(
    String response,
    int days,
    DateTime startDate,
  ) {
    try {
      final data = jsonDecode(response);

      final dailyPlans = (data['dailyPlans'] as List).map((day) {
        return DailyMealPlan.fromJson(day);
      }).toList();

      final ingredients = (data['ingredients'] as List).map((item) {
        return Ingredient.fromJson(item);
      }).toList();

      return GeneratedMealData(
        dailyPlans: dailyPlans,
        ingredients: ingredients,
      );
    } catch (e) {
      debugPrint('응답 파싱 오류: $e');
      return null;
    }
  }

  /// 단일 끼니 응답 파싱
  Meal? _parseSingleMealResponse(String response, MealType mealType) {
    try {
      final data = jsonDecode(response);
      return Meal.fromJson(data);
    } catch (e) {
      debugPrint('끼니 파싱 오류: $e');
      return null;
    }
  }

  /// 끼니 유형 목록 생성
  List<MealType> _getMealTypesForCount(int count) {
    switch (count) {
      case 2:
        return [MealType.lunch, MealType.dinner];
      case 3:
        return [MealType.breakfast, MealType.lunch, MealType.dinner];
      case 4:
        return [
          MealType.breakfast,
          MealType.lunch,
          MealType.dinner,
          MealType.snack,
        ];
      case 5:
        return [
          MealType.breakfast,
          MealType.snack,
          MealType.lunch,
          MealType.snack,
          MealType.dinner,
        ];
      default:
        return [MealType.breakfast, MealType.lunch, MealType.dinner];
    }
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
