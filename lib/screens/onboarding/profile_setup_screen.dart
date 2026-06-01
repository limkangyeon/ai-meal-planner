import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;
  const ProfileSetupScreen({super.key, this.isEditing = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // 사용자 입력값
  DietGoal? _selectedGoal;
  final Set<String> _selectedAllergies = {};
  final List<String> _preferredFoods = [];
  final List<String> _dislikedFoods = [];
  int _mealsPerDay = 3;
  CookingDifficulty _cookingDifficulty = CookingDifficulty.medium;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final profile = context.read<UserProvider>().userProfile;
        if (profile != null) {
          setState(() {
            _selectedGoal = profile.dietGoal;
            _selectedAllergies.addAll(profile.allergies);
            _preferredFoods.addAll(profile.preferredFoods);
            _dislikedFoods.addAll(profile.dislikedFoods);
            _mealsPerDay = profile.mealsPerDay;
            _cookingDifficulty = profile.cookingDifficulty;
          });
        }
      });
    }
  }

  // 텍스트 컨트롤러
  final _preferredFoodController = TextEditingController();
  final _dislikedFoodController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _preferredFoodController.dispose();
    _dislikedFoodController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveProfile() async {
    final userProvider = context.read<UserProvider>();

    final success = await userProvider.updateProfile(
      dietGoal: _selectedGoal,
      allergies: _selectedAllergies.toList(),
      preferredFoods: _preferredFoods,
      dislikedFoods: _dislikedFoods,
      mealsPerDay: _mealsPerDay,
      cookingDifficulty: _cookingDifficulty,
    );

    if (success) {
      if (widget.isEditing) {
        if (mounted) context.pop();
      } else {
        await userProvider.completeOnboarding();
        if (mounted) context.go('/home');
      }
    }
  }

  void _skipSetup() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.skipOnboarding();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          TextButton(
            onPressed: _skipSetup,
            child: const Text('건너뛰기'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행률 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_currentStep + 1} / $_totalSteps',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),

          // 페이지 뷰
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _buildGoalStep(),
                _buildAllergyStep(),
                _buildPreferenceStep(),
                _buildMealsPerDayStep(),
                _buildDifficultyStep(),
              ],
            ),
          ),

          // 다음 버튼
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text(
                  _currentStep < _totalSteps - 1 ? '다음' : '완료',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 1: 식단 목표 선택
  Widget _buildGoalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '식단 목표를 선택해주세요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI가 목표에 맞는 식단을 추천해드려요',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          ...DietGoal.values.map((goal) => _buildGoalCard(goal)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(DietGoal goal) {
    final isSelected = _selectedGoal == goal;

    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              goal.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
              ),
          ],
        ),
      ),
    );
  }

  // Step 2: 알러지 선택
  Widget _buildAllergyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '알러지가 있으신가요?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '선택한 재료는 식단에서 제외됩니다',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AllergyType.commonAllergies.map((allergy) {
              final isSelected = _selectedAllergies.contains(allergy);
              return FilterChip(
                label: Text(allergy),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAllergies.add(allergy);
                    } else {
                      _selectedAllergies.remove(allergy);
                    }
                  });
                },
                selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryGreen,
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          Text(
            '없으면 바로 다음으로 넘어가세요',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: 선호/비선호 음식
  Widget _buildPreferenceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '음식 취향을 알려주세요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '좋아하는 음식은 더 자주, 싫어하는 음식은 제외해요',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // 선호 음식
          Text(
            '좋아하는 음식',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _preferredFoodController,
                  decoration: const InputDecoration(
                    hintText: '예: 김치찌개, 파스타',
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _preferredFoods.add(value);
                        _preferredFoodController.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  final value = _preferredFoodController.text;
                  if (value.isNotEmpty) {
                    setState(() {
                      _preferredFoods.add(value);
                      _preferredFoodController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add_circle),
                color: AppTheme.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _preferredFoods.map((food) {
              return Chip(
                label: Text(food),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() => _preferredFoods.remove(food));
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // 비선호 음식
          Text(
            '싫어하는 음식',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dislikedFoodController,
                  decoration: const InputDecoration(
                    hintText: '예: 고수, 미나리',
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _dislikedFoods.add(value);
                        _dislikedFoodController.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  final value = _dislikedFoodController.text;
                  if (value.isNotEmpty) {
                    setState(() {
                      _dislikedFoods.add(value);
                      _dislikedFoodController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add_circle),
                color: Colors.red.shade400,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dislikedFoods.map((food) {
              return Chip(
                label: Text(food),
                backgroundColor: Colors.red.shade50,
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() => _dislikedFoods.remove(food));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Step 4: 하루 식사 횟수
  Widget _buildMealsPerDayStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '하루에 몇 끼 드시나요?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '끼니 수에 맞춰 식단을 구성해요',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 48),

          Center(
            child: Column(
              children: [
                Text(
                  '$_mealsPerDay끼',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                Slider(
                  value: _mealsPerDay.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (value) {
                    setState(() => _mealsPerDay = value.round());
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  _getMealsDescription(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMealsDescription() {
    switch (_mealsPerDay) {
      case 1:
        return '하루 한 끼';
      case 2:
        return '점심, 저녁';
      case 3:
        return '아침, 점심, 저녁';
      case 4:
        return '아침, 점심, 저녁, 간식';
      case 5:
        return '아침, 간식, 점심, 간식, 저녁';
      default:
        return '';
    }
  }

  // Step 5: 조리 난이도
  Widget _buildDifficultyStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어느 정도 요리할 수 있나요?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '난이도에 맞는 레시피를 추천해드려요',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          ...CookingDifficulty.values.map((difficulty) {
            final isSelected = _cookingDifficulty == difficulty;
            return GestureDetector(
              onTap: () => setState(() => _cookingDifficulty = difficulty),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDifficultyIcon(difficulty),
                      size: 32,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            difficulty.displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            difficulty.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryGreen,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(CookingDifficulty difficulty) {
    switch (difficulty) {
      case CookingDifficulty.easy:
        return Icons.timer;
      case CookingDifficulty.medium:
        return Icons.soup_kitchen;
      case CookingDifficulty.hard:
        return Icons.restaurant;
    }
  }
}
