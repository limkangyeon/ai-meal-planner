import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/user_provider.dart';

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
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final userProvider = context.read<UserProvider>();
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? true;

    if (userProvider.isLoggedIn) {
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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 아이콘
            Image.asset(
              'assets/icon/icon.png',
              width: 110,
              height: 110,
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 24),

            // 앱 이름 "EatPlan"
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Eat',
                    style: GoogleFonts.poppins(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4CAF50),
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Plan',
                    style: GoogleFonts.poppins(
                      fontSize: 38,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF2E7D32),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 8),

            // 슬로건
            Text(
              'AI 맞춤 식단 플래너',
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: Colors.grey.shade400,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w400,
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms),

            const SizedBox(height: 60),

            // 로딩 점 애니메이션
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(
                      delay: Duration(milliseconds: 800 + i * 150),
                      duration: 400.ms,
                    )
                    .then()
                    .fadeOut(duration: 400.ms);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
