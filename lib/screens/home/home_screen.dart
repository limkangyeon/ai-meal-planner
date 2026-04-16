import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/meal_plan.dart';
import '../../providers/user_provider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/meal_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final mealPlanProvider = context.read<MealPlanProvider>();

    if (userProvider.userId.isNotEmpty) {
      await mealPlanProvider.loadMealPlans(userProvider.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                _buildHeader(),
                const SizedBox(height: 24),

                // 오늘의 식단 카드
                _buildTodayMealCard(),
                const SizedBox(height: 24),

                // 빠른 액션 버튼들
                _buildQuickActions(),
                const SizedBox(height: 24),

                // 인기 식단 섹션
                _buildPopularMealsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        final name = provider.userProfile?.displayName ?? '회원';
        final greeting = _getGreeting();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$name님! 👋',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                // TODO: 알림 페이지
              },
              icon: const Icon(Icons.notifications_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '좋은 아침이에요';
    if (hour < 18) return '좋은 오후에요';
    return '좋은 저녁이에요';
  }

  Widget _buildTodayMealCard() {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final currentPlan = provider.currentPlan;

        if (currentPlan == null) {
          return _buildEmptyMealCard();
        }

        // 오늘의 식단 찾기
        final today = DateTime.now();
        DailyMealPlan? todayPlan;
        try {
          todayPlan = currentPlan.dailyPlans.firstWhere(
            (plan) =>
                plan.date.year == today.year &&
                plan.date.month == today.month &&
                plan.date.day == today.day,
          );
        } catch (_) {
          todayPlan = null;
        }

        if (todayPlan == null) {
          return _buildEmptyMealCard();
        }

        return _buildMealSummaryCard(todayPlan, currentPlan.id);
      },
    );
  }

  Widget _buildEmptyMealCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 식단이 없어요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI가 당신만을 위한 맞춤 식단을 추천해드려요',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/meal-plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('식단 생성하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSummaryCard(DailyMealPlan todayPlan, String planId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘의 식단',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/meal-plan/$planId'),
                child: const Text('전체보기'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 끼니별 요약
          ...todayPlan.meals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        meal.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.type.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${meal.nutrition.calories}kcal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )),

          const Divider(height: 24),

          // 총 칼로리
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 칼로리',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${todayPlan.totalNutrition.calories}kcal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.add_circle_outline,
            label: '새 식단',
            color: AppTheme.primaryGreen,
            onTap: () => context.go('/generate-meal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.shopping_cart_outlined,
            label: '장보기',
            color: AppTheme.secondaryOrange,
            onTap: () {
              final provider = context.read<MealPlanProvider>();
              if (provider.currentPlan != null) {
                context.go('/shopping-list/${provider.currentPlan!.id}');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('먼저 식단을 생성해주세요')),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.history,
            label: '히스토리',
            color: Colors.blue,
            onTap: () => context.go('/profile'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🔥 인기 식단',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/community'),
              child: const Text('더보기'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 플레이스홀더 카드들
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '다이어트',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '일주일 건강식단',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${50 + index * 23}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
