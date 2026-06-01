import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


import '../../models/meal_plan.dart';
import '../../models/user_profile.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/nutrition_chart.dart';

class MealPlanDetailScreen extends StatefulWidget {
  final String planId;

  const MealPlanDetailScreen({
    super.key,
    required this.planId,
  });

  @override
  State<MealPlanDetailScreen> createState() => _MealPlanDetailScreenState();
}

class _MealPlanDetailScreenState extends State<MealPlanDetailScreen> {
  MealPlan? _mealPlan;

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    final provider = context.read<MealPlanProvider>();
    final plan = await provider.getMealPlan(widget.planId);
    if (plan != null && mounted) {
      setState(() => _mealPlan = plan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealPlan = _mealPlan;

    if (mealPlan == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('식단 상세'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 오늘 날짜 인덱스
    final today = DateTime.now();
    final todayIndex = mealPlan.dailyPlans.indexWhere((d) =>
        d.date.year == today.year &&
        d.date.month == today.month &&
        d.date.day == today.day);
    final initialIndex = todayIndex >= 0 ? todayIndex : 0;

    return DefaultTabController(
      length: mealPlan.dailyPlans.length,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
          title: Text(
            '${mealPlan.durationDays}일 식단',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(
                mealPlan.isShared ? Icons.people : Icons.people_outline,
                color: Colors.white,
              ),
              tooltip: mealPlan.isShared ? '공유 중' : '커뮤니티 공유',
              onPressed: _shareMealPlan,
            ),
            PopupMenuButton<String>(
              iconColor: Colors.white,
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'shopping', child: Row(children: [Icon(Icons.shopping_cart), SizedBox(width: 8), Text('장보기 리스트')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('삭제', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: mealPlan.dailyPlans.map((plan) {
              final isToday = plan.date.year == DateTime.now().year &&
                  plan.date.month == DateTime.now().month &&
                  plan.date.day == DateTime.now().day;
              return Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_weekday(plan.date), style: const TextStyle(fontSize: 11)),
                    Text('${plan.date.day}일', style: TextStyle(fontSize: 14, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: mealPlan.dailyPlans.map((dailyPlan) {
            return _buildDayContent(dailyPlan);
          }).toList(),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/shopping-list/${widget.planId}'),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('장보기 리스트 보기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContent(DailyMealPlan dailyPlan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 영양 정보 요약
          NutritionSummaryCard(nutrition: dailyPlan.totalNutrition),
          
          const SizedBox(height: 20),

          // 끼니별 식단
          ...dailyPlan.meals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MealCard(
                  meal: meal,
                  onTap: () => _showMealDetail(meal),
                  onLike: () => _toggleLike(meal),
                  onRegenerate: () => _regenerateMeal(dailyPlan.date, meal.type),
                ),
              )),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('M월 d일').format(date);
  }

  String _weekday(DateTime date) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[date.weekday - 1];
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'shopping':
        context.push('/shopping-list/${widget.planId}');
        break;
      case 'regenerate':
        _confirmRegenerate();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  void _shareMealPlan() {
    final mealPlan = _mealPlan;
    if (mealPlan == null) return;

    final isShared = mealPlan.isShared;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isShared ? '공유 취소' : '커뮤니티에 공유'),
        content: Text(isShared
            ? '이 식단의 공유를 취소하시겠어요?'
            : '이 식단을 커뮤니티에 공유하면\n다른 사용자들이 볼 수 있어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<MealPlanProvider>();
              bool success;
              if (isShared) {
                success = await provider.unshareMealPlan(mealPlan.id);
              } else {
                final userProfile = context.read<UserProvider>().userProfile;
                success = await provider.shareMealPlan(
                  mealPlan.id,
                  authorName: userProfile?.displayName ?? '익명',
                  dietGoalName: userProfile?.dietGoal?.displayName,
                );
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? (isShared ? '공유가 취소되었습니다' : '커뮤니티에 공유되었습니다!')
                      : '처리 중 오류가 발생했습니다'),
                ));
                if (success) setState(() => _mealPlan = _mealPlan?.copyWith(isShared: !isShared));
              }
            },
            style: isShared ? ElevatedButton.styleFrom(backgroundColor: Colors.red) : null,
            child: Text(isShared ? '공유 취소' : '공유하기'),
          ),
        ],
      ),
    );
  }

  void _showMealDetail(Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 핸들
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 헤더
                Row(
                  children: [
                    Text(
                      meal.type.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.type.displayName,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 설명
                if (meal.description != null) ...[
                  Text(
                    meal.description!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 영양 정보
                const Text(
                  '영양 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                NutritionSummaryCard(nutrition: meal.nutrition),

                const SizedBox(height: 20),

                // 재료
                const Text(
                  '재료',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: meal.ingredients.map((ingredient) {
                    return Chip(
                      label: Text(ingredient),
                      backgroundColor: Colors.grey.shade100,
                    );
                  }).toList(),
                ),

                // 레시피
                if (meal.recipe != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    '조리법',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      meal.recipe!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleLike(Meal meal) {
    final provider = context.read<MealPlanProvider>();
    provider.rateMeal(
      planId: widget.planId,
      mealId: meal.id,
      isLiked: !meal.isLiked,
    );
  }

  void _regenerateMeal(DateTime date, MealType mealType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('식단 재생성'),
        content: const Text('이 끼니를 다시 추천받으시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 재생성 로직
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('재생성 기능은 준비 중입니다')),
              );
            },
            child: const Text('재생성'),
          ),
        ],
      ),
    );
  }

  void _confirmRegenerate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 재생성'),
        content: const Text('모든 식단을 새로 추천받으시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/generate-meal?days=${_mealPlan?.durationDays ?? 7}');
            },
            child: const Text('재생성'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('식단 삭제'),
        content: const Text('이 식단을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<MealPlanProvider>();
              await provider.deleteMealPlan(widget.planId);
              if (mounted) {
                context.go('/home');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

// 날짜 탭바 델리게이트
class _DateTabBarDelegate extends SliverPersistentHeaderDelegate {
  final List<DailyMealPlan> dailyPlans;

  _DateTabBarDelegate({required this.dailyPlans});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        isScrollable: true,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryGreen,
        tabs: dailyPlans.map((plan) {
          final isToday = _isToday(plan.date);
          return Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getWeekday(plan.date),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${plan.date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isToday)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
