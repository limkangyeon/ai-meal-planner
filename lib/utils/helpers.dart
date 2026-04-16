import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// 날짜 포맷팅 유틸리티
class DateUtils {
  static final DateFormat _dateFormat = DateFormat('M월 d일');
  static final DateFormat _dateFormatFull = DateFormat('yyyy년 M월 d일');
  static final DateFormat _dateFormatShort = DateFormat('M/d');
  static final DateFormat _weekdayFormat = DateFormat('E', 'ko_KR');
  
  /// M월 d일 형식
  static String formatDate(DateTime date) => _dateFormat.format(date);
  
  /// yyyy년 M월 d일 형식
  static String formatDateFull(DateTime date) => _dateFormatFull.format(date);
  
  /// M/d 형식
  static String formatDateShort(DateTime date) => _dateFormatShort.format(date);
  
  /// 요일 (월, 화, ...)
  static String getWeekday(DateTime date) => _weekdayFormat.format(date);
  
  /// 오늘인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// 날짜 범위 문자열
  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatDateShort(start)} - ${formatDateShort(end)}';
  }
}

/// 숫자 포맷팅 유틸리티
class NumberUtils {
  static final NumberFormat _numberFormat = NumberFormat('#,###');
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.0');
  
  /// 천 단위 콤마
  static String formatNumber(num number) => _numberFormat.format(number);
  
  /// 소수점 1자리
  static String formatDecimal(num number) => _decimalFormat.format(number);
  
  /// 칼로리 표시
  static String formatCalories(int calories) => '$calories kcal';
  
  /// 그램 표시
  static String formatGrams(double grams) => '${grams.toStringAsFixed(0)}g';
}

/// 유효성 검사 유틸리티
class Validators {
  /// 이메일 유효성 검사
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '유효한 이메일을 입력해주세요';
    }
    return null;
  }
  
  /// 비밀번호 유효성 검사
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다';
    }
    return null;
  }
  
  /// 필수 입력 검사
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }
}

/// 색상 유틸리티
class ColorUtils {
  /// 영양소 색상
  static Color getNutrientColor(String nutrient) {
    switch (nutrient.toLowerCase()) {
      case 'carbohydrates':
      case '탄수화물':
        return const Color(0xFF4CAF50);  // 녹색
      case 'protein':
      case '단백질':
        return const Color(0xFF2196F3);  // 파랑
      case 'fat':
      case '지방':
        return const Color(0xFFFF9800);  // 주황
      default:
        return Colors.grey;
    }
  }
  
  /// 칼로리 기준 색상
  static Color getCalorieColor(int calories) {
    if (calories < 400) return Colors.green;
    if (calories < 600) return Colors.orange;
    return Colors.red;
  }
}

/// 스낵바 유틸리티
class SnackBarUtils {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// 앱 상수
class AppConstants {
  static const String appName = 'AI Meal Planner';
  static const String appVersion = '1.0.0';
  
  // 식단 설정
  static const int minMealPlanDays = 1;
  static const int maxMealPlanDays = 14;
  static const int defaultMealPlanDays = 7;
  
  // 캐싱 설정
  static const Duration cacheExpiry = Duration(hours: 24);
  
  // 페이지네이션
  static const int pageSize = 20;
}
