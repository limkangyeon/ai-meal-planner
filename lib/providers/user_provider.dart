import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _firebaseUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _isOnboarded = false;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isOnboarded => _isOnboarded;
  String get userId => _firebaseUser?.uid ?? '';

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    // 인증 상태 변화 감지
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      _error = null;
      if (user != null) {
        await _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });

    // 온보딩 상태 확인
    final prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool('onboarding_completed') ?? false;
  }

  /// 사용자 프로필 로드
  Future<void> _loadUserProfile() async {
    if (_firebaseUser == null) return;

    // 메모리에 기본 프로필을 먼저 설정 (Firestore 실패해도 앱이 동작하도록)
    _userProfile ??= UserProfile(
      id: _firebaseUser!.uid,
      email: _firebaseUser!.email,
      displayName: _firebaseUser!.displayName,
      photoUrl: _firebaseUser!.photoURL,
    );

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();

      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc);
      } else {
        await _saveUserProfile();
      }
    } catch (e) {
      _error = '프로필을 불러오는 데 실패했습니다: $e';
    }
  }

  /// 프로필 저장
  Future<void> _saveUserProfile() async {
    if (_userProfile == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userProfile!.id)
          .set(_userProfile!.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      _error = '프로필 저장 실패: $e';
    }
  }

  /// Google 로그인
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 취소
        _setLoading(false);
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _firebaseUser = userCredential.user;
      await _loadUserProfile();

      // 로그인 유지 ON으로 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', true);

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      _error = 'Google 로그인 중 오류가 발생했습니다';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 이메일 회원가입
  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = credential.user;
      await _loadUserProfile();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      _error = '회원가입 중 오류가 발생했습니다';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 이메일 로그인
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = credential.user;
      await _loadUserProfile();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      return false;
    } catch (e) {
      _error = '로그인 중 오류가 발생했습니다';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    _firebaseUser = null;
    _userProfile = null;
    notifyListeners();
  }

  /// 프로필 편집 (이름 + 사진)
  Future<void> updateProfileWithPhoto({
    required String displayName,
    String? photoUrl,
  }) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(
      displayName: displayName,
      photoUrl: photoUrl,
      updatedAt: DateTime.now(),
    );
    await _saveUserProfile();
    notifyListeners();
  }

  /// 프로필 업데이트
  Future<bool> updateProfile({
    String? displayName,
    DietGoal? dietGoal,
    List<String>? allergies,
    List<String>? preferredFoods,
    List<String>? dislikedFoods,
    int? mealsPerDay,
    int? budgetMin,
    int? budgetMax,
    CookingDifficulty? cookingDifficulty,
  }) async {
    if (_userProfile == null && _firebaseUser != null) {
      _userProfile = UserProfile(
        id: _firebaseUser!.uid,
        email: _firebaseUser!.email,
        displayName: _firebaseUser!.displayName,
        photoUrl: _firebaseUser!.photoURL,
      );
    }
    if (_userProfile == null) return false;

    _setLoading(true);
    _error = null;

    try {
      _userProfile = _userProfile!.copyWith(
        displayName: displayName ?? _userProfile!.displayName,
        dietGoal: dietGoal ?? _userProfile!.dietGoal,
        allergies: allergies ?? _userProfile!.allergies,
        preferredFoods: preferredFoods ?? _userProfile!.preferredFoods,
        dislikedFoods: dislikedFoods ?? _userProfile!.dislikedFoods,
        mealsPerDay: mealsPerDay ?? _userProfile!.mealsPerDay,
        budgetMin: budgetMin ?? _userProfile!.budgetMin,
        budgetMax: budgetMax ?? _userProfile!.budgetMax,
        cookingDifficulty: cookingDifficulty ?? _userProfile!.cookingDifficulty,
        updatedAt: DateTime.now(),
      );

      await _saveUserProfile();
      notifyListeners();
      return true;
    } catch (e) {
      _error = '프로필 업데이트 실패: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 온보딩 완료 처리
  Future<void> completeOnboarding() async {
    if (_userProfile == null && _firebaseUser != null) {
      _userProfile = UserProfile(
        id: _firebaseUser!.uid,
        email: _firebaseUser!.email,
        displayName: _firebaseUser!.displayName,
        photoUrl: _firebaseUser!.photoURL,
      );
    }
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(onboardingCompleted: true);
    await _saveUserProfile();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _isOnboarded = true;

    notifyListeners();
  }

  /// 온보딩 스킵 (프로필 설정 없이)
  Future<void> skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _isOnboarded = true;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다';
      case 'weak-password':
        return '비밀번호는 6자 이상이어야 합니다';
      // Firebase Auth v5에서 통합된 코드 (이메일 없거나 비밀번호 틀림)
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return '이메일 또는 비밀번호가 올바르지 않습니다';
      case 'user-disabled':
        return '비활성화된 계정입니다. 고객센터에 문의해주세요';
      case 'too-many-requests':
        return '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요';
      default:
        return '이메일 또는 비밀번호가 올바르지 않습니다';
    }
  }
}
