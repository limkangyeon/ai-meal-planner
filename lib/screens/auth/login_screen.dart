import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _rememberMeKey = 'remember_me';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _rememberMe = prefs.getBool(_rememberMeKey) ?? true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, _rememberMe);

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      if (userProvider.userProfile?.onboardingCompleted ?? false) {
        context.go('/home');
      } else {
        context.go('/profile-setup');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // 로고
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 40,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 제목
              Center(
                child: Text(
                  '다시 오신 것을 환영해요!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  '로그인하고 식단 관리를 계속하세요',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 폼
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 이메일
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        hintText: 'example@email.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        if (!value.contains('@')) {
                          return '유효한 이메일을 입력해주세요';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 비밀번호
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        hintText: '비밀번호를 입력하세요',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // 로그인 유지 + 비밀번호 찾기
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (v) => setState(() => _rememberMe = v ?? true),
                              activeColor: AppTheme.primaryGreen,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              child: const Text('로그인 유지', style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: 비밀번호 찾기
                          },
                          child: const Text('비밀번호 찾기'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 에러 메시지
                    Consumer<UserProvider>(
                      builder: (context, provider, _) {
                        if (provider.error != null) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              provider.error!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // 로그인 버튼
                    Consumer<UserProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _login,
                            child: provider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    '로그인',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 회원가입 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '아직 계정이 없으신가요?',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text('회원가입'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
