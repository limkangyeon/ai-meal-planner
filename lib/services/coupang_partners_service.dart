import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 쿠팡 파트너스 서비스
/// 
/// 계획서 기반 수익 모델:
/// - 판매 금액의 3-10% 수수료 (식품 평균 4-5%)
/// - 예상 월 수익 (사용자 1,000명): 9만원
/// - 손익분기점: 약 150명
class CoupangPartnersService {
  // 쿠팡 파트너스 설정
  // 실제 파트너 코드는 .env 파일에서 관리
  String get _partnerCode => dotenv.env['COUPANG_PARTNER_CODE'] ?? 'YOUR_PARTNER_CODE';
  
  static const String _baseUrl = 'https://link.coupang.com/a';
  static const String _searchBaseUrl = 'https://www.coupang.com/np/search';
  
  // 싱글톤 패턴
  static final CoupangPartnersService _instance = CoupangPartnersService._internal();
  factory CoupangPartnersService() => _instance;
  CoupangPartnersService._internal();

  /// 파트너 코드 설정 여부
  bool get hasPartnerCode =>
      _partnerCode.isNotEmpty && _partnerCode != 'YOUR_PARTNER_CODE';

  /// 제품 검색 링크 생성 (파트너 코드 있으면 제휴 링크, 없으면 직접 검색)
  String getProductLink(String keyword) {
    final encodedKeyword = Uri.encodeComponent(keyword);
    if (hasPartnerCode) {
      // 쿠팡 파트너스 제휴 링크 (검색 페이지)
      return '$_baseUrl/$_partnerCode?subId=eatplan&pageType=SEARCH&searchKeyword=$encodedKeyword';
    } else {
      // 파트너 코드 없을 때 직접 검색 (기능은 동작, 수수료만 없음)
      return '$_searchBaseUrl?q=$encodedKeyword';
    }
  }

  /// 여러 재료를 한번에 검색하는 링크 생성
  String getBulkShoppingLink(List<String> ingredients) {
    final limitedIngredients = ingredients.take(5).toList();
    final keywords = limitedIngredients.join(' ');
    return getProductLink(keywords);
  }

  /// 쿠팡 링크 열기
  /// 
  /// [keyword] 검색할 키워드
  /// 
  /// 외부 브라우저 또는 쿠팡 앱으로 열림
  Future<bool> openCoupangLink(String keyword) async {
    final url = getProductLink(keyword);
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,  // 외부 앱/브라우저에서 열기
      );

      if (launched) {
        // 링크 클릭 통계 저장 (분석용)
        await _trackLinkClick(keyword);
      }

      return launched;
    } catch (e) {
      debugPrint('쿠팡 링크 열기 실패: $e');
      return false;
    }
  }

  /// 장보기 리스트 한번에 구매 링크 열기
  Future<bool> openBulkShoppingLink(List<String> ingredients) async {
    final url = getBulkShoppingLink(ingredients);
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        await _trackBulkClick(ingredients.length);
      }

      return launched;
    } catch (e) {
      debugPrint('쿠팡 장보기 링크 열기 실패: $e');
      return false;
    }
  }

  /// 제휴 마케팅 고지 표시 여부 확인
  Future<bool> shouldShowAffiliateNotice() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('affiliate_notice_shown') ?? false);
  }

  /// 제휴 마케팅 고지 확인 완료 저장
  Future<void> markAffiliateNoticeShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('affiliate_notice_shown', true);
  }

  /// 링크 클릭 통계 저장 (로컬)
  Future<void> _trackLinkClick(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 총 클릭 수
      final totalClicks = prefs.getInt('coupang_total_clicks') ?? 0;
      await prefs.setInt('coupang_total_clicks', totalClicks + 1);
      
      // 오늘 클릭 수
      final today = DateTime.now().toIso8601String().split('T')[0];
      final dailyKey = 'coupang_clicks_$today';
      final dailyClicks = prefs.getInt(dailyKey) ?? 0;
      await prefs.setInt(dailyKey, dailyClicks + 1);
    } catch (e) {
      debugPrint('통계 저장 실패: $e');
    }
  }

  /// 한번에 구매 클릭 통계
  Future<void> _trackBulkClick(int ingredientCount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bulkClicks = prefs.getInt('coupang_bulk_clicks') ?? 0;
      await prefs.setInt('coupang_bulk_clicks', bulkClicks + 1);
    } catch (e) {
      debugPrint('통계 저장 실패: $e');
    }
  }

  /// 클릭 통계 조회
  Future<Map<String, int>> getClickStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    return {
      'total': prefs.getInt('coupang_total_clicks') ?? 0,
      'today': prefs.getInt('coupang_clicks_$today') ?? 0,
      'bulk': prefs.getInt('coupang_bulk_clicks') ?? 0,
    };
  }

  /// 법적 고지 문구
  /// 
  /// 공정거래위원회 가이드라인 준수
  static const String legalNotice = 
    '이 어플리케이션은 쿠팡 파트너스 활동의 일환으로, '
    '이에 따른 일정액의 수수료를 제공받습니다.';

  /// 짧은 고지 문구 (버튼 하단용)
  static const String shortNotice = 
    '* 쿠팡 파트너스 활동으로 일정액의 수수료를 받습니다';

  /// 카테고리별 추천 검색 키워드
  /// 
  /// 재료명만으로는 검색이 잘 안 될 수 있어서
  /// 카테고리에 맞는 추가 키워드 제공
  static String getOptimizedKeyword(String ingredientName, String category) {
    switch (category) {
      case '채소':
        return '$ingredientName 신선';
      case '과일':
        return '$ingredientName 과일';
      case '육류':
        return '$ingredientName 고기';
      case '해산물':
        return '$ingredientName 수산';
      case '유제품':
        return ingredientName;
      case '곡류':
        return ingredientName;
      case '조미료':
        return '$ingredientName 조미료';
      default:
        return ingredientName;
    }
  }
}
