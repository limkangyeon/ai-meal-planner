import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/user_provider.dart';
import '../../services/coupang_partners_service.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 알림 설정
            _buildSectionTitle('알림'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: '푸시 알림',
                subtitle: '식단 알림, 장보기 알림 등',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
            ]),

            // 화면 설정
            _buildSectionTitle('화면'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: '다크 모드',
                subtitle: '어두운 테마 사용',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                  // TODO: 실제 다크모드 적용
                },
              ),
            ]),

            // 앱 정보
            _buildSectionTitle('앱 정보'),
            _buildSettingsCard([
              _buildNavigationTile(
                icon: Icons.info_outline,
                title: '앱 버전',
                trailing: '1.0.0',
                onTap: () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () => _openUrl('https://example.com/terms'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                onTap: () => _openUrl('https://example.com/privacy'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.open_source,
                title: '오픈소스 라이선스',
                onTap: () => showLicensePage(context: context),
              ),
            ]),

            // 제휴 마케팅 정보
            _buildSectionTitle('제휴 정보'),
            _buildAffiliateInfoCard(),

            // 계정
            _buildSectionTitle('계정'),
            _buildSettingsCard([
              _buildNavigationTile(
                icon: Icons.logout,
                title: '로그아웃',
                textColor: Colors.red,
                onTap: () => _confirmLogout(context),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.delete_forever,
                title: '회원 탈퇴',
                textColor: Colors.red,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? trailing,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: trailing != null
          ? Text(
              trailing,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            )
          : Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildAffiliateInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.coupangRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: AppTheme.coupangRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '쿠팡 파트너스',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '제휴 마케팅 안내',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              CoupangPartnersService.legalNotice,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '장보기 리스트에서 쿠팡 링크를 통해 구매하시면 일정액의 수수료가 개발자에게 지급됩니다. '
            '이 수수료는 앱 운영 및 개선에 사용됩니다.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<UserProvider>();
              await provider.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text(
          '정말 탈퇴하시겠습니까?\n\n'
          '탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 회원 탈퇴 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('회원 탈퇴 기능은 준비 중입니다')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
  }
}
