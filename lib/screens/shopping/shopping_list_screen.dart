import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/meal_plan.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/shopping_list_provider.dart';
import '../../services/coupang_partners_service.dart';
import '../../utils/app_theme.dart';

class ShoppingListScreen extends StatefulWidget {
  final String planId;

  const ShoppingListScreen({
    super.key,
    required this.planId,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final CoupangPartnersService _coupangService = CoupangPartnersService();
  bool _showPurchased = false;

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
    _checkAffiliateNotice();
  }

  Future<void> _loadShoppingList() async {
    final mealPlanProvider = context.read<MealPlanProvider>();
    final shoppingProvider = context.read<ShoppingListProvider>();

    final plan = await mealPlanProvider.getMealPlan(widget.planId);
    if (plan != null) {
      shoppingProvider.loadFromMealPlan(plan);
    }
  }

  Future<void> _checkAffiliateNotice() async {
    if (await _coupangService.shouldShowAffiliateNotice()) {
      if (mounted) {
        _showAffiliateNoticeDialog();
      }
    }
  }

  void _showAffiliateNoticeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shopping_bag, color: AppTheme.coupangRed),
            SizedBox(width: 8),
            Text('쇼핑 편의 기능 안내'),
          ],
        ),
        content: const Text(
          '본 앱은 쿠팡 파트너스 활동의 일환으로, '
          '쿠팡 링크를 통한 구매 시 일정액의 수수료를 제공받습니다.\n\n'
          '이는 앱 운영 및 개선에 사용됩니다.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _coupangService.markAffiliateNoticeShown();
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('장보기 리스트'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareList,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_purchased',
                child: Row(
                  children: [
                    Icon(_showPurchased 
                        ? Icons.visibility_off 
                        : Icons.visibility),
                    const SizedBox(width: 8),
                    Text(_showPurchased ? '구매완료 숨기기' : '구매완료 보기'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt),
                    SizedBox(width: 8),
                    Text('체크 초기화'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ShoppingListProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.ingredients.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // 진행률 헤더
              _buildProgressHeader(provider),
              
              // 쿠팡 한번에 구매 버튼
              _buildCoupangBulkButton(provider),
              
              // 재료 리스트
              Expanded(
                child: _buildIngredientList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '장보기 리스트가 비어있어요',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/meal-plan'),
            child: const Text('식단 생성하러 가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(ShoppingListProvider provider) {
    final total = provider.ingredients.length;
    final purchased = provider.purchasedIngredients.length;
    final progress = provider.progress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$purchased / $total 완료',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryGreen,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildCoupangBulkButton(ShoppingListProvider provider) {
    final pendingIngredients = provider.pendingIngredients;
    
    if (pendingIngredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openCoupangBulk(pendingIngredients),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.coupangRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag),
                  SizedBox(width: 8),
                  Text(
                    '쿠팡에서 한번에 구매하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _coupangService.hasPartnerCode
                ? CoupangPartnersService.shortNotice
                : '* 쿠팡에서 직접 검색합니다',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientList(ShoppingListProvider provider) {
    final ingredientsByCategory = provider.ingredientsByCategory;
    final categories = ingredientsByCategory.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final ingredients = ingredientsByCategory[category]!;

        // 구매 완료 필터링
        final filteredIngredients = _showPurchased
            ? ingredients
            : ingredients.where((i) => !provider.isPurchased(i.id)).toList();

        if (filteredIngredients.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildCategorySection(category, filteredIngredients, provider);
      },
    );
  }

  Widget _buildCategorySection(
    String category,
    List<Ingredient> ingredients,
    ShoppingListProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${ingredients.length}개',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ...ingredients.map((ingredient) {
          return _buildIngredientItem(ingredient, provider);
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildIngredientItem(
    Ingredient ingredient,
    ShoppingListProvider provider,
  ) {
    final isPurchased = provider.isPurchased(ingredient.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isPurchased ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: () => provider.togglePurchased(ingredient.id),
        leading: Checkbox(
          value: isPurchased,
          onChanged: (_) => provider.togglePurchased(ingredient.id),
          activeColor: AppTheme.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          ingredient.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: isPurchased ? TextDecoration.lineThrough : null,
            color: isPurchased ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Text(
          ingredient.quantityDisplay,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.coupangRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: AppTheme.coupangRed,
              size: 20,
            ),
          ),
          onPressed: () => _openCoupangItem(ingredient),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    final provider = context.read<ShoppingListProvider>();
    
    switch (action) {
      case 'toggle_purchased':
        setState(() => _showPurchased = !_showPurchased);
        break;
      case 'clear_all':
        provider.clearAllPurchased();
        break;
    }
  }

  Future<void> _shareList() async {
    final provider = context.read<ShoppingListProvider>();
    final text = provider.toShareText();
    await Share.share(text);
  }

  Future<void> _openCoupangItem(Ingredient ingredient) async {
    final keyword = CoupangPartnersService.getOptimizedKeyword(
      ingredient.name,
      ingredient.category,
    );
    await _coupangService.openCoupangLink(keyword);
  }

  Future<void> _openCoupangBulk(List<Ingredient> ingredients) async {
    final keywords = ingredients.map((i) => i.name).toList();
    await _coupangService.openBulkShoppingLink(keywords);
  }
}
