import 'package:flutter/material.dart';

import '../services/coupang_partners_service.dart';
import '../utils/app_theme.dart';

/// 쿠팡 한번에 구매하기 버튼
class CoupangBulkPurchaseButton extends StatelessWidget {
  final List<String> ingredients;
  final VoidCallback? onPressed;

  const CoupangBulkPurchaseButton({
    super.key,
    required this.ingredients,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final coupangService = CoupangPartnersService();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  onPressed?.call();
                  await coupangService.openBulkShoppingLink(ingredients);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.coupangRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://image7.coupangcdn.com/image/coupang/favicon/v2/favicon.ico',
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '쿠팡에서 한번에 구매하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CoupangPartnersService.shortNotice,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 개별 재료 쿠팡 링크 버튼
class CoupangItemButton extends StatelessWidget {
  final String ingredientName;
  final String? category;

  const CoupangItemButton({
    super.key,
    required this.ingredientName,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final coupangService = CoupangPartnersService();

    return SizedBox(
      width: 60,
      child: ElevatedButton(
        onPressed: () async {
          final keyword = category != null
              ? CoupangPartnersService.getOptimizedKeyword(
                  ingredientName, category!)
              : ingredientName;
          await coupangService.openCoupangLink(keyword);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.coupangRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '쿠팡',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 제휴 마케팅 고지 팝업
class AffiliateNoticeDialog extends StatelessWidget {
  const AffiliateNoticeDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    final coupangService = CoupangPartnersService();
    final shouldShow = await coupangService.shouldShowAffiliateNotice();

    if (shouldShow && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AffiliateNoticeDialog(),
      );
      await coupangService.markAffiliateNoticeShown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '쇼핑 편의 기능 안내',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '본 앱은 쿠팡 파트너스 활동의 일환으로, 쿠팡 링크를 통한 구매 시 일정액의 수수료를 제공받습니다.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '수수료는 앱 운영 및 개선에 사용됩니다.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ),
      ],
    );
  }
}

/// 설정 페이지용 제휴 마케팅 안내 카드
class AffiliateInfoCard extends StatelessWidget {
  const AffiliateInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.handshake_outlined,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                const Text(
                  '제휴 마케팅 안내',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              CoupangPartnersService.legalNotice,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '장보기 리스트에서 쿠팡 링크를 통해 재료를 편리하게 구매하실 수 있습니다. '
              '이는 선택 사항이며, 강제되지 않습니다.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
