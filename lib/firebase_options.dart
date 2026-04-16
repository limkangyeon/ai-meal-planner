// Firebase 설정 파일
// FlutterFire CLI로 자동 생성하거나 직접 설정하세요
// 명령어: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android 설정
  // Firebase Console에서 google-services.json 다운로드 후 
  // android/app/ 폴더에 배치하세요
  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? 'YOUR_API_KEY',
    appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? 'YOUR_APP_ID',
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'YOUR_SENDER_ID',
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'YOUR_PROJECT_ID',
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'YOUR_BUCKET',
  );

  // iOS 설정
  // Firebase Console에서 GoogleService-Info.plist 다운로드 후
  // ios/Runner/ 폴더에 배치하세요
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? 'YOUR_API_KEY',
    appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? 'YOUR_APP_ID',
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'YOUR_SENDER_ID',
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'YOUR_PROJECT_ID',
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'YOUR_BUCKET',
    iosBundleId: 'com.aimealplanner.app',
  );
}
