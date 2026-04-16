# Firebase 설정 가이드

이 문서는 AI Meal Planner 앱에서 Firebase를 설정하는 방법을 안내합니다.

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com)에 접속
2. **프로젝트 추가** 클릭
3. 프로젝트 이름 입력: `ai-meal-planner`
4. Google Analytics 설정 (선택사항)
5. 프로젝트 생성 완료

## 2. Flutter 앱 등록

### Android 앱 등록

1. Firebase Console에서 **Android 아이콘** 클릭
2. Android 패키지 이름 입력: `com.aimealplanner.ai_meal_planner`
3. 앱 닉네임 입력 (선택): `AI Meal Planner`
4. SHA-1 인증서 지문 입력 (선택, 추후 추가 가능)
5. **앱 등록** 클릭

#### google-services.json 설정

1. `google-services.json` 다운로드
2. 파일을 `android/app/` 폴더에 복사
3. `android/build.gradle` 수정:
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```
4. `android/app/build.gradle` 수정:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### iOS 앱 등록 (선택)

1. Firebase Console에서 **iOS 아이콘** 클릭
2. iOS 번들 ID 입력: `com.aimealplanner.aiMealPlanner`
3. **앱 등록** 클릭

#### GoogleService-Info.plist 설정

1. `GoogleService-Info.plist` 다운로드
2. Xcode에서 `ios/Runner/` 폴더에 파일 추가
3. **Copy items if needed** 체크

## 3. Firebase 서비스 활성화

### Firestore Database

1. Firebase Console → **Build** → **Firestore Database**
2. **데이터베이스 만들기** 클릭
3. **프로덕션 모드** 선택 (나중에 규칙 수정)
4. 위치 선택: `asia-northeast3` (서울)
5. 완료

#### Firestore 보안 규칙

**Firestore Database** → **규칙** 탭에서 아래 규칙 적용:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 프로필 - 본인만 읽기/쓰기
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 식단 계획 - 본인만 읽기/쓰기
    match /mealPlans/{planId} {
      allow read, write: if request.auth != null && 
                          resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // 공유된 식단 - 모든 인증된 사용자 읽기, 작성자만 쓰기
    match /sharedMealPlans/{planId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    // 평가 - 본인만 쓰기
    match /ratings/{ratingId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### Authentication

1. Firebase Console → **Build** → **Authentication**
2. **시작하기** 클릭
3. **이메일/비밀번호** 활성화
4. (선택) **Google 로그인** 활성화

## 4. Firebase SDK 초기화

`lib/main.dart`에서 Firebase가 올바르게 초기화되는지 확인:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

## 5. 테스트

Firebase 연결 테스트:

```bash
flutter run
```

앱이 정상적으로 실행되고 오류가 없으면 Firebase 설정이 완료된 것입니다.

## 문제 해결

### 일반적인 오류

1. **google-services.json not found**
   - 파일이 `android/app/` 폴더에 있는지 확인
   - 파일 이름이 정확한지 확인

2. **FirebaseApp has not been initialized**
   - `Firebase.initializeApp()` 호출 확인
   - `await` 키워드 사용 확인

3. **PERMISSION_DENIED**
   - Firestore 보안 규칙 확인
   - 사용자 인증 상태 확인

### 도움이 필요하면

- [Firebase 공식 문서](https://firebase.google.com/docs)
- [FlutterFire 문서](https://firebase.flutter.dev)
