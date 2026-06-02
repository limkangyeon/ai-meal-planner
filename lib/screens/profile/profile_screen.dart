import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/user_provider.dart';
import '../../providers/meal_plan_provider.dart';
import '../../utils/app_theme.dart';
import '../onboarding/profile_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 헤더
            _buildProfileHeader(context),
            
            const SizedBox(height: 20),
            
            // 통계 카드
            _buildStatsCard(context),
            
            const SizedBox(height: 20),
            
            // 메뉴 섹션
            _buildMenuSection(context),
            
            const SizedBox(height: 20),
            
            // 식단 히스토리
            _buildMealHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        final profile = provider.userProfile;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
          ),
          child: Row(
            children: [
              // 프로필 이미지
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                  image: profile?.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(profile!.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profile?.photoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // 프로필 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.displayName ?? '회원',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (profile?.dietGoal != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${profile!.dietGoal!.icon} ${profile.dietGoal!.displayName}',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // 연필 아이콘 → 이름/프로필 편집
              IconButton(
                onPressed: () => context.push('/edit-profile'),
                icon: const Icon(Icons.edit),
                color: AppTheme.primaryGreen,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        final totalPlans = provider.mealPlans.length;
        final likedCount = provider.likedPlanIds.length;
        final sharedCount = provider.mealPlans.where((p) => p.isShared).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('생성한 식단', '$totalPlans', Icons.restaurant_menu),
                _buildStatItem('좋아요한 식단', '$likedCount', Icons.favorite),
                _buildStatItem('공유한 식단', '$sharedCount', Icons.share),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
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
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: '프로필 편집 (이름)',
              onTap: () => context.push('/edit-profile'),
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.tune,
              title: '식단 목표/설정 변경',
              onTap: () => _editProfile(context),
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.history,
              title: '식단 히스토리',
              onTap: () => context.push('/history?tab=0'),
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.favorite_border,
              title: '좋아요한 식단',
              onTap: () => context.push('/history?tab=2'),
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.share,
              title: '공유한 식단',
              onTap: () => context.push('/history?tab=1'),
            ),
            _buildDivider(),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: '도움말',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildMealHistory(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 식단',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Consumer<MealPlanProvider>(
            builder: (context, provider, _) {
              if (provider.mealPlans.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '아직 생성한 식단이 없어요',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.go('/meal-plan'),
                        child: const Text('식단 생성하기'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: provider.mealPlans.take(5).map((plan) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => context.push('/meal-plan/${plan.id}'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Theme.of(context).colorScheme.surface,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      title: Text(
                        '${plan.durationDays}일 식단',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${plan.startDate.month}/${plan.startDate.day} ~ ${plan.endDate.month}/${plan.endDate.day}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(isEditing: true),
      ),
    );
  }
}
