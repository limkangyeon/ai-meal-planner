import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/meal_plan_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  int _selectedDays = 7;
  DateTime _startDate = DateTime.now();

  final List<int> _dayOptions = [1, 3, 5, 7, 14];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 생성'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 설명
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withOpacity(0.1),
                    AppTheme.primaryGreenLight.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI가 맞춤 식단을 만들어드려요',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '목표, 알러지, 선호도를 고려한\n건강한 식단을 추천받으세요',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 기간 선택
            const Text(
              '식단 기간',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '며칠간의 식단을 만들까요?',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // 기간 선택 칩
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _dayOptions.map((days) {
                final isSelected = _selectedDays == days;
                return ChoiceChip(
                  label: Text(
                    days == 1 ? '1일' : '$days일',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGreen,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDays = days);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // 시작 날짜
            const Text(
              '시작 날짜',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '언제부터 시작할까요?',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // 날짜 선택 버튼
            InkWell(
              onTap: _selectStartDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(_startDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 예상 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '식단 정보',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('기간', '$_selectedDays일'),
                  _buildInfoRow(
                    '종료일',
                    _formatDate(_startDate.add(Duration(days: _selectedDays - 1))),
                  ),
                  _buildInfoRow('예상 생성 시간', '10-15초'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 이전 식단 목록
            _buildPreviousMealPlans(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _generateMealPlan,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome),
                  SizedBox(width: 8),
                  Text(
                    'AI 식단 생성하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.blue.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousMealPlans() {
    return Consumer<MealPlanProvider>(
      builder: (context, provider, _) {
        if (provider.mealPlans.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이전 식단',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...provider.mealPlans.take(3).map((plan) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => context.go('/meal-plan/${plan.id}'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.grey.shade100,
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
                    '${_formatDate(plan.startDate)} ~ ${_formatDate(plan.endDate)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.month}월 ${date.day}일 ($weekday)';
  }

  void _generateMealPlan() {
    context.go('/generate-meal?days=$_selectedDays&startDate=${_startDate.toIso8601String()}');
  }
}
