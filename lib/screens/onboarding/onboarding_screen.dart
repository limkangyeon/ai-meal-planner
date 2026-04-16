import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.restaurant_menu,
      title: 'AI 맞춤 식단',
      description: 'AI가 당신의 목표와 취향에 맞는\n완벽한 식단을 추천해드려요',
      color: AppTheme.primaryGreen,
    ),
    OnboardingPage(
      icon: Icons.calendar_month,
      title: '간편한 식단 관리',
      description: '1일부터 14일까지\n원하는 기간의 식단을 한번에 생성',
      color: AppTheme.secondaryOrange,
    ),
    OnboardingPage(
      icon: Icons.shopping_cart,
      title: '장보기 리스트',
      description: '필요한 재료를 자동으로 정리하고\n쿠팡에서 바로 구매까지',
      color: Colors.blue,
    ),
    OnboardingPage(
      icon: Icons.people,
      title: '커뮤니티 공유',
      description: '다른 사용자들의 인기 식단을\n참고하고 공유해보세요',
      color: Colors.purple,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToSignup();
    }
  }

  void _goToSignup() {
    context.go('/signup');
  }

  void _skipOnboarding() {
    context.go('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 건너뛰기 버튼
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  '건너뛰기',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // 페이지 뷰
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // 페이지 인디케이터
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: WormEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  spacing: 8,
                  dotColor: Colors.grey.shade300,
                  activeDotColor: AppTheme.primaryGreen,
                ),
              ),
            ),

            // 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  child: Text(
                    _currentPage < _pages.length - 1 ? '다음' : '시작하기',
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
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘 컨테이너
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 48),

          // 제목
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 16),

          // 설명
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
