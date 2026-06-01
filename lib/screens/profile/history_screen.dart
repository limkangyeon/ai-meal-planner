import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/meal_plan.dart';
import '../../providers/meal_plan_provider.dart';
import '../../utils/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final int initialTab;
  const HistoryScreen({super.key, this.initialTab = 0});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MealPlanProvider>();
      // 내 식단 목록은 이미 로드돼 있을 수 있으므로 로드되지 않은 경우만
      if (provider.mealPlans.isEmpty) {
        // UserProvider에서 userId를 가져오는 건 caller에서 처리되어야 함
        // 여기선 이미 로드된 데이터를 활용
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 기록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: '내 식단'),
            Tab(text: '공유한 식단'),
            Tab(text: '좋아요'),
          ],
        ),
      ),
      body: Consumer<MealPlanProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMyPlans(provider),
              _buildSharedPlans(provider),
              _buildLikedPlans(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMyPlans(MealPlanProvider provider) {
    final plans = provider.mealPlans;
    if (plans.isEmpty) {
      return _buildEmpty('아직 생성한 식단이 없어요', '식단을 생성해보세요!', Icons.restaurant_menu);
    }
    return _buildPlanList(plans);
  }

  Widget _buildSharedPlans(MealPlanProvider provider) {
    final plans = provider.mealPlans.where((p) => p.isShared).toList();
    if (plans.isEmpty) {
      return _buildEmpty('공유한 식단이 없어요', '커뮤니티에 식단을 공유해보세요!', Icons.people_outline);
    }
    return _buildPlanList(plans);
  }

  Widget _buildLikedPlans(MealPlanProvider provider) {
    // 커뮤니티에서 좋아요한 공유 식단 표시
    final plans = provider.sharedPlans.where((p) => p.likes > 0).toList();
    if (plans.isEmpty) {
      return _buildEmpty('좋아요한 식단이 없어요', '커뮤니티에서 마음에 드는 식단에\n좋아요를 눌러보세요!', Icons.favorite_border);
    }
    return _buildPlanList(plans);
  }

  Widget _buildPlanList(List<MealPlan> plans) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) => _buildPlanCard(plans[index]),
    );
  }

  Widget _buildPlanCard(MealPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: () => context.push('/meal-plan/${plan.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.restaurant_menu, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${plan.durationDays}일 식단',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (plan.isShared) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('공유중', style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.startDate.month}/${plan.startDate.day} ~ ${plan.endDate.month}/${plan.endDate.day}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '평균 ${plan.averageNutrition.calories}kcal/일',
                        style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade500), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
