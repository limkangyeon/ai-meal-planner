import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_provider.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final userProvider = context.read<UserProvider>();
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? true;

    if (userProvider.isLoggedIn) {
      // 로그인 유지 OFF인 경우 자동 로그아웃
      if (!rememberMe) {
        await userProvider.signOut();
        if (!mounted) return;
        context.go('/login');
        return;
      }

      if (userProvider.isOnboarded) {
        context.go('/home');
      } else {
        context.go('/profile-setup');
      }
    } else {
      if (userProvider.isOnboarded) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
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
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 24),

            // 앱 이름
            Text(
              'AI Meal Planner',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 8),

            // 슬로건
            Text(
              '당신만을 위한 맞춤 식단',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms),

            const SizedBox(height: 48),

            // 로딩 인디케이터
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }
}
