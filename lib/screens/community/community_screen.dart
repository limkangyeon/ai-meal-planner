import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/meal_plan.dart';
import '../../providers/meal_plan_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = '전체';

  final List<String> _categories = ['전체', '다이어트', '근육증가', '건강관리', '체중증가', '기타'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MealPlanProvider>();
      final userId = context.read<UserProvider>().userId;
      provider.loadSharedMealPlans();
      if (userId.isNotEmpty) provider.loadLikedPlanIds(userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MealPlan> _filtered(List<MealPlan> plans) {
    if (_selectedCategory == '전체') return plans;
    return plans.where((p) => p.dietGoalName == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: '인기 식단'),
            Tab(text: '최신 식단'),
          ],
        ),
      ),
      body: Consumer<MealPlanProvider>(
        builder: (context, provider, _) {
          final plans = provider.sharedPlans;

          return Column(
            children: [
              _buildCategoryFilter(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(
                      plans: [..._filtered(plans)]..sort((a, b) => b.likes.compareTo(a.likes)),
                      provider: provider,
                    ),
                    _buildList(
                      plans: [..._filtered(plans)]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
                      provider: provider,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/meal-plan'),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text('내 식단 공유', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.primaryGreen,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
              selectedColor: AppTheme.primaryGreen,
              checkmarkColor: Colors.white,
              side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.4)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList({required List<MealPlan> plans, required MealPlanProvider provider}) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('아직 공유된 식단이 없어요', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('첫 번째로 식단을 공유해보세요!', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadSharedMealPlans(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) => _buildCard(plans[index], provider),
      ),
    );
  }

  Widget _buildCard(MealPlan plan, MealPlanProvider provider) {
    final isLiked = provider.isLiked(plan.id);
    final dietGoal = plan.dietGoalName;
    final authorName = plan.authorName ?? '익명';
    final avgCalories = plan.dailyPlans.isNotEmpty
        ? plan.averageNutrition.calories
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => context.push('/meal-plan/${plan.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (dietGoal != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _categoryColor(dietGoal).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(dietGoal, style: TextStyle(color: _categoryColor(dietGoal), fontSize: 12, fontWeight: FontWeight.w600)),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      Icon(Icons.favorite, color: isLiked ? Colors.red : Colors.grey.shade400, size: 18),
                      const SizedBox(width: 4),
                      Text('${plan.likes}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${plan.durationDays}일 식단',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${plan.startDate.month}/${plan.startDate.day} ~ ${plan.endDate.month}/${plan.endDate.day} · $authorName',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoChip(Icons.calendar_today, '${plan.durationDays}일'),
                  const SizedBox(width: 8),
                  if (avgCalories > 0) _infoChip(Icons.local_fire_department, '${avgCalories}kcal/일'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.restaurant, '${plan.ingredients.length}가지 재료'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final userId = context.read<UserProvider>().userId;
                        if (userId.isNotEmpty) {
                          provider.toggleLike(plan.id, userId);
                        }
                      },
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: Text(isLiked ? '좋아요 취소' : '좋아요'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/meal-plan/${plan.id}'),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('상세보기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case '다이어트': return Colors.orange;
      case '근육증가': return Colors.blue;
      case '건강관리': return AppTheme.primaryGreen;
      case '체중증가': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
