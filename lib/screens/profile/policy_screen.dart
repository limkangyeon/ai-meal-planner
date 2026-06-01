import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PolicyScreen extends StatelessWidget {
  final PolicyType type;
  const PolicyScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type == PolicyType.terms ? '이용약관' : '개인정보 처리방침'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profile'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: type == PolicyType.terms ? _buildTerms() : _buildPrivacy(),
      ),
    );
  }

  Widget _buildTerms() {
    return const _PolicyContent(
      title: '이용약관',
      lastUpdated: '2026년 6월 1일',
      sections: [
        _Section('제1조 (목적)', '이 약관은 AI 식단 플래너(이하 "서비스")의 이용 조건 및 절차, 회사와 이용자의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.'),
        _Section('제2조 (정의)', '① "서비스"란 AI 기술을 활용한 개인 맞춤 식단 추천 및 관리 서비스를 의미합니다.\n② "이용자"란 이 약관에 따라 서비스를 이용하는 회원을 말합니다.'),
        _Section('제3조 (약관의 효력 및 변경)', '① 이 약관은 서비스를 이용하고자 하는 모든 이용자에게 적용됩니다.\n② 회사는 필요한 경우 약관을 변경할 수 있으며, 변경된 약관은 앱 내 공지를 통해 안내합니다.'),
        _Section('제4조 (서비스의 제공)', '① 서비스는 AI 기반 식단 생성, 영양 정보 제공, 장보기 목록 생성, 커뮤니티 기능을 제공합니다.\n② AI가 생성한 식단은 참고 목적이며, 의학적 진단이나 치료를 대체하지 않습니다.'),
        _Section('제5조 (이용자의 의무)', '① 이용자는 타인의 개인정보를 수집하거나 저장하면 안 됩니다.\n② 서비스를 상업적 목적으로 무단 이용해서는 안 됩니다.\n③ 불법적이거나 서비스 운영을 방해하는 행위를 해서는 안 됩니다.'),
        _Section('제6조 (서비스 이용 제한)', '회사는 이용자가 약관을 위반하는 경우 사전 통보 없이 서비스 이용을 제한할 수 있습니다.'),
        _Section('제7조 (면책 조항)', '① 회사는 천재지변 또는 불가항력적 사유로 인한 서비스 제공 불능에 대해 책임을 지지 않습니다.\n② AI 식단 추천 결과로 인한 건강 문제에 대해 회사는 책임을 지지 않습니다.'),
        _Section('제8조 (준거법 및 관할)', '이 약관은 대한민국 법령에 따라 해석되며, 분쟁 발생 시 관할 법원은 민사소송법에 따라 결정됩니다.'),
      ],
    );
  }

  Widget _buildPrivacy() {
    return const _PolicyContent(
      title: '개인정보 처리방침',
      lastUpdated: '2026년 6월 1일',
      sections: [
        _Section('1. 수집하는 개인정보', '서비스는 다음의 개인정보를 수집합니다:\n• 필수: 이메일 주소, 비밀번호\n• 선택: 닉네임, 식단 목표, 알러지 정보, 선호/비선호 음식'),
        _Section('2. 개인정보 수집 목적', '• 회원 가입 및 서비스 제공\n• AI 맞춤 식단 생성\n• 서비스 개선 및 통계 분석\n• 법령상 의무 이행'),
        _Section('3. 개인정보 보유 및 이용 기간', '• 회원 탈퇴 시까지 보유\n• 관련 법령에 따른 보존 기간이 있는 경우 해당 기간까지 보관\n• 식단 데이터: 회원 탈퇴 후 즉시 삭제'),
        _Section('4. 개인정보의 제3자 제공', '서비스는 이용자의 동의 없이 개인정보를 제3자에게 제공하지 않습니다. 단, 법령에 의한 경우는 예외입니다.'),
        _Section('5. 개인정보 처리 위탁', '서비스는 원활한 운영을 위해 다음 업체에 처리를 위탁합니다:\n• Google Firebase (인증, 데이터 저장)\n• Google Gemini API (AI 식단 생성)'),
        _Section('6. 이용자의 권리', '이용자는 언제든지 자신의 개인정보를 조회, 수정, 삭제를 요청할 수 있습니다. 요청은 앱 내 프로필 설정에서 가능합니다.'),
        _Section('7. 개인정보 보호책임자', '개인정보 처리에 관한 문의는 앱 내 고객센터를 통해 연락해 주세요.'),
        _Section('8. 쿠키 및 자동수집 정보', '서비스는 서비스 개선을 위해 기기 정보, 앱 사용 기록 등을 자동으로 수집할 수 있습니다.'),
      ],
    );
  }
}

enum PolicyType { terms, privacy }

class _PolicyContent extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<_Section> sections;

  const _PolicyContent({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('최종 수정일: $lastUpdated', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const Divider(height: 32),
        ...sections.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(s.content, style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.6)),
            ],
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _Section {
  final String title;
  final String content;
  const _Section(this.title, this.content);
}
