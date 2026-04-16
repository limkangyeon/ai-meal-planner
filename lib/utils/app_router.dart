import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_navigation_screen.dart';
import '../screens/meal_plan/meal_plan_screen.dart';
import '../screens/meal_plan/meal_plan_detail_screen.dart';
import '../screens/meal_plan/meal_generation_screen.dart';
import '../screens/shopping/shopping_list_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    
    routes: [
      // 스플래시 화면
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 온보딩
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // 프로필 설정 (온보딩 후)
      GoRoute(
        path: '/profile-setup',
        name: 'profileSetup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      
      // 인증 화면들
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // 메인 네비게이션 (하단 탭바)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainNavigationScreen(child: child),
        routes: [
          // 홈 탭
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          
          // 식단 생성 탭
          GoRoute(
            path: '/meal-plan',
            name: 'mealPlan',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MealPlanScreen(),
            ),
          ),
          
          // 커뮤니티 탭
          GoRoute(
            path: '/community',
            name: 'community',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommunityScreen(),
            ),
          ),
          
          // 마이페이지 탭
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      
      // 식단 생성 화면 (풀스크린)
      GoRoute(
        path: '/generate-meal',
        name: 'generateMeal',
        builder: (context, state) => const MealGenerationScreen(),
      ),
      
      // 식단 상세 화면
      GoRoute(
        path: '/meal-plan/:id',
        name: 'mealPlanDetail',
        builder: (context, state) {
          final planId = state.pathParameters['id']!;
          return MealPlanDetailScreen(planId: planId);
        },
      ),
      
      // 장보기 리스트 화면
      GoRoute(
        path: '/shopping-list/:planId',
        name: 'shoppingList',
        builder: (context, state) {
          final planId = state.pathParameters['planId']!;
          return ShoppingListScreen(planId: planId);
        },
      ),
      
      // 설정 화면
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    
    // 에러 페이지
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
    
    // 리다이렉트 로직
    redirect: (context, state) {
      // TODO: 인증 상태에 따른 리다이렉트 로직 추가
      // final isLoggedIn = context.read<UserProvider>().isLoggedIn;
      // final isOnboarded = context.read<UserProvider>().isOnboarded;
      
      return null;
    },
  );
}
