import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이용약관에 동의해주세요')),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go('/profile-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                '회원가입',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'AI 맞춤 식단을 시작하세요',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 32),

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
                        hintText: '6자 이상 입력하세요',
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
                        if (value.length < 6) {
                          return '비밀번호는 6자 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 비밀번호 확인
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
                        hintText: '비밀번호를 다시 입력하세요',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() =>
                                _obscureConfirmPassword = !_obscureConfirmPassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 다시 입력해주세요';
                        }
                        if (value != _passwordController.text) {
                          return '비밀번호가 일치하지 않습니다';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // 이용약관 동의
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() => _agreeToTerms = value ?? false);
                          },
                          activeColor: AppTheme.primaryGreen,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _agreeToTerms = !_agreeToTerms);
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: '(필수) '),
                                  TextSpan(
                                    text: '이용약관',
                                    style: TextStyle(
                                      color: AppTheme.primaryGreen,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: ' 및 '),
                                  TextSpan(
                                    text: '개인정보처리방침',
                                    style: TextStyle(
                                      color: AppTheme.primaryGreen,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: '에 동의합니다'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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

                    // 회원가입 버튼
                    Consumer<UserProvider>(
                      builder: (context, provider, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _signup,
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
                                    '가입하기',
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

              // 로그인 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미 계정이 있으신가요?',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('로그인'),
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
