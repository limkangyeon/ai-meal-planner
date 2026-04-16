# 🍽️ AI Meal Planner

AI 기반 맞춤형 식단 추천 모바일 어플리케이션

## ✨ 주요 기능

- 🤖 **AI 맞춤 식단 생성**: Gemini 2.5 Flash-Lite를 활용한 개인 맞춤형 식단 추천
- 📅 **유연한 기간 설정**: 1일 ~ 14일 단위 식단 생성
- 🛒 **장보기 리스트**: 필요한 재료 자동 정리 및 쿠팡 연동
- 💬 **커뮤니티**: 인기 식단 공유 및 추천
- ⭐ **평가 시스템**: 식단 평가로 AI 개인화 향상

## 🛠️ 기술 스택

- **Frontend**: Flutter 3.x (Dart)
- **Backend**: Firebase (Firestore, Auth, Storage)
- **AI**: Google Gemini 2.5 Flash-Lite API
- **수익 모델**: 쿠팡 파트너스 제휴 마케팅

## 📱 스크린샷

(앱 완성 후 추가 예정)

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- Android Studio / VS Code
- Firebase 프로젝트

### 설치

1. **저장소 클론**
   ```bash
   git clone https://github.com/your-username/ai_meal_planner.git
   cd ai_meal_planner
   ```

2. **환경 변수 설정**
   ```bash
   cp .env.example .env
   # .env 파일을 열어 API 키 입력
   ```

3. **Firebase 설정**
   - Firebase Console에서 프로젝트 생성
   - Android/iOS 앱 등록
   - `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) 다운로드
   - 각각 `android/app/` 및 `ios/Runner/`에 배치

4. **의존성 설치**
   ```bash
   flutter pub get
   ```

5. **실행**
   ```bash
   flutter run
   ```

## ⚙️ 환경 설정

### Gemini API 키 발급

1. [Google AI Studio](https://ai.google.dev) 접속
2. API 키 생성
3. `.env` 파일에 `GEMINI_API_KEY` 추가

### 쿠팡 파트너스 가입

1. [쿠팡 파트너스](https://partners.coupang.com) 접속
2. 회원가입 및 앱 정보 등록
3. 심사 승인 후 파트너 코드 발급
4. `.env` 파일에 `COUPANG_PARTNER_CODE` 추가

### Firebase 설정

1. [Firebase Console](https://console.firebase.google.com) 접속
2. 새 프로젝트 생성
3. Firestore Database 활성화
4. Authentication 활성화 (이메일/비밀번호)
5. Flutter 앱 등록 및 설정 파일 다운로드

## 📁 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── user_profile.dart
│   └── meal_plan.dart
├── providers/                # 상태 관리
│   ├── user_provider.dart
│   ├── meal_plan_provider.dart
│   └── shopping_list_provider.dart
├── screens/                  # 화면
│   ├── splash_screen.dart
│   ├── onboarding/
│   ├── auth/
│   ├── home/
│   ├── meal_plan/
│   ├── shopping/
│   ├── community/
│   └── profile/
├── services/                 # 서비스
│   ├── gemini_service.dart
│   └── coupang_partners_service.dart
├── utils/                    # 유틸리티
│   ├── app_theme.dart
│   └── app_router.dart
└── widgets/                  # 공통 위젯
    ├── meal_card.dart
    └── nutrition_chart.dart
```

## 💰 수익 모델

- **쿠팡 파트너스**: 장보기 리스트에서 쿠팡으로 구매 시 판매액의 3-10% 수수료
- **예상 손익분기점**: 사용자 약 150명
- **예상 월 수익 (1,000명 기준)**: 약 14.5만원

## 📊 개발 일정

- [x] Phase 1: 기획 및 설계 (1주)
- [ ] Phase 2: 개발 환경 설정 (1주)
- [ ] Phase 3: 핵심 기능 개발 (5주)
- [ ] Phase 4: 커뮤니티 기능 (2주)
- [ ] Phase 5: 테스트 및 최적화 (2주)
- [ ] Phase 6: 배포 (1주)

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 📞 문의

- 이메일: support@aimealplanner.com
- 이슈: [GitHub Issues](https://github.com/your-username/ai_meal_planner/issues)

---

Made with ❤️ by 1인 개발자
