import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  final List<String> _categories = [
    '전체',
    '다이어트',
    '근육증가',
    '건강관리',
    '체중증가',
  ];

  // 샘플 데이터 (실제로는 Firestore에서 가져옴)
  final List<Map<String, dynamic>> _sampleMealPlans = [
    {
      'id': '1',
      'title': '일주일 다이어트 식단',
      'category': '다이어트',
      'likes': 152,
      'days': 7,
      'calories': 1500,
      'description': '건강하게 체중 감량을 위한 균형 잡힌 식단',
    },
    {
      'id': '2',
      'title': '고단백 벌크업 식단',
      'category': '근육증가',
      'likes': 98,
      'days': 5,
      'calories': 2500,
      'description': '근육량 증가를 위한 고단백 식단',
    },
    {
      'id': '3',
      'title': '직장인 간편 건강식',
      'category': '건강관리',
      'likes': 234,
      'days': 7,
      'calories': 1800,
      'description': '바쁜 직장인을 위한 간편하고 건강한 식단',
    },
    {
      'id': '4',
      'title': '저탄고지 키토 식단',
      'category': '다이어트',
      'likes': 87,
      'days': 14,
      'calories': 1600,
      'description': '케토제닉 다이어트를 위한 저탄수화물 식단',
    },
    {
      'id': '5',
      'title': '비건 영양 균형 식단',
      'category': '건강관리',
      'likes': 65,
      'days': 7,
      'calories': 1700,
      'description': '채식주의자를 위한 영양 균형 식단',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      body: Column(
        children: [
          // 카테고리 필터
          _buildCategoryFilter(),
          
          // 식단 리스트
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMealPlanList(sortByLikes: true),
                _buildMealPlanList(sortByLikes: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareMealPlan,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.share),
        label: const Text('내 식단 공유'),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
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
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryGreen,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealPlanList({required bool sortByLikes}) {
    var filteredPlans = _selectedCategory == '전체'
        ? _sampleMealPlans
        : _sampleMealPlans
            .where((p) => p['category'] == _selectedCategory)
            .toList();

    if (sortByLikes) {
      filteredPlans.sort((a, b) => b['likes'].compareTo(a['likes']));
    }

    if (filteredPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 공유된 식단이 없어요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째로 식단을 공유해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPlans.length,
      itemBuilder: (context, index) {
        return _buildMealPlanCard(filteredPlans[index]);
      },
    );
  }

  Widget _buildMealPlanCard(Map<String, dynamic> plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showMealPlanDetail(plan),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 태그
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(plan['category']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plan['category'],
                      style: TextStyle(
                        color: _getCategoryColor(plan['category']),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plan['likes']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 제목
              Text(
                plan['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 설명
              Text(
                plan['description'],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // 정보
              Row(
                children: [
                  _buildInfoChip(Icons.calendar_today, '${plan['days']}일'),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.local_fire_department, '${plan['calories']}kcal/일'),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _likeMealPlan(plan['id']),
                      icon: const Icon(Icons.favorite_border, size: 18),
                      label: const Text('좋아요'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _addToMyPlan(plan),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('내 식단에'),
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '다이어트':
        return Colors.orange;
      case '근육증가':
        return Colors.blue;
      case '건강관리':
        return AppTheme.primaryGreen;
      case '체중증가':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showMealPlanDetail(Map<String, dynamic> plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                
                Text(
                  plan['title'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan['description'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                
                // 상세 정보
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('기간', '${plan['days']}일'),
                      const Divider(),
                      _buildDetailRow('일 평균 칼로리', '${plan['calories']}kcal'),
                      const Divider(),
                      _buildDetailRow('카테고리', plan['category']),
                      const Divider(),
                      _buildDetailRow('좋아요', '${plan['likes']}명'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _addToMyPlan(plan);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('내 식단에 추가하기'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _likeMealPlan(String planId) {
    // TODO: 좋아요 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('좋아요를 눌렀습니다!')),
    );
  }

  void _addToMyPlan(Map<String, dynamic> plan) {
    // TODO: 내 식단에 추가 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${plan['title']}"을(를) 내 식단에 추가했습니다!')),
    );
  }

  void _shareMealPlan() {
    // TODO: 내 식단 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('내 식단 공유 기능은 준비 중입니다')),
    );
  }
}
