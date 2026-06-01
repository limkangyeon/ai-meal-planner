import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/meal_plan_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class MealGenerationScreen extends StatefulWidget {
  const MealGenerationScreen({super.key});

  @override
  State<MealGenerationScreen> createState() => _MealGenerationScreenState();
}

class _MealGenerationScreenState extends State<MealGenerationScreen> {
  bool _isGenerating = false;
  String _statusMessage = 'AI가 맞춤 식단을 준비하고 있어요...';
  int _currentTipIndex = 0;

  final List<String> _tips = [
    '💡 하루 2L의 물을 마시면 신진대사가 활발해져요',
    '🥗 채소를 먼저 먹으면 혈당 상승을 늦출 수 있어요',
    '🍎 과일은 식후보다 식전에 먹는 것이 좋아요',
    '🥚 단백질은 포만감을 오래 유지시켜줘요',
    '🌙 저녁은 가볍게 먹는 것이 숙면에 도움돼요',
    '🏃 식후 가벼운 산책은 소화를 도와줘요',
  ];

  @override
  void initState() {
    super.initState();
    _startTipRotation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isGenerating) {
      _startGeneration();
    }
  }

  void _startTipRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isGenerating) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
        });
        _startTipRotation();
      }
    });
  }

  Future<void> _startGeneration() async {
    setState(() => _isGenerating = true);

    final userProvider = context.read<UserProvider>();
    final mealPlanProvider = context.read<MealPlanProvider>();

    // URL 파라미터에서 days와 startDate 가져오기
    final uri = GoRouterState.of(context).uri;
    final days = int.tryParse(uri.queryParameters['days'] ?? '7') ?? 7;
    final startDateStr = uri.queryParameters['startDate'];
    final startDate = startDateStr != null 
        ? DateTime.tryParse(startDateStr) ?? DateTime.now()
        : DateTime.now();

    if (userProvider.userProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 정보가 필요합니다')),
        );
        context.go('/profile-setup');
      }
      return;
    }

    // 상태 메시지 업데이트
    _updateStatus('사용자 프로필 분석 중...');
    await Future.delayed(const Duration(milliseconds: 500));

    _updateStatus('AI가 최적의 식단을 계산하고 있어요...');

    final result = await mealPlanProvider.generateMealPlan(
      userId: userProvider.userId,
      userProfile: userProvider.userProfile!,
      days: days,
      startDate: startDate,
    );

    if (!mounted) return;

    if (result != null) {
      _updateStatus('식단 생성 완료! 🎉');
      await Future.delayed(const Duration(milliseconds: 500));
      context.go('/home');
    } else {
      setState(() => _isGenerating = false);
      _showErrorDialog(mealPlanProvider.error ?? '식단 생성에 실패했습니다');
    }
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() => _statusMessage = message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/meal-plan');
            },
            child: const Text('확인'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGeneration();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // 애니메이션 아이콘
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: AppTheme.primaryGreen,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 1.seconds,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(1, 1),
                    duration: 1.seconds,
                  ),

              const SizedBox(height: 40),

              // 상태 메시지
              Text(
                _statusMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(),

              const SizedBox(height: 24),

              // 진행률
              Consumer<MealPlanProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: provider.generationProgress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(provider.generationProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Spacer(),

              // 팁 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '알고 계셨나요?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _tips[_currentTipIndex],
                        key: ValueKey(_currentTipIndex),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 취소 버튼
              TextButton(
                onPressed: () => context.go('/meal-plan'),
                child: Text(
                  '취소',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
