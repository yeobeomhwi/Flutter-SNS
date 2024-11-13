import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  // 로그인
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("로그인 중 오류 발생: ${e.message}");
      throw FirebaseAuthException(code: e.code, message: e.message); // 오류 다시 던지기
    }
  }

  //구글 로그인
  // 구글 로그인
  Future<String> signInWithGoogle() async {
    try {
      // 구글 인증 흐름 시작
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // 인증 정보를 가져옴
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Firebase 인증 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Firebase로 로그인
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      // Firestore에서 사용자 문서 확인 및 새 사용자일 경우 추가
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Firestore에 새 사용자 정보 저장
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'email': user.email,
            'profileImage': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return '로그인 성공';
    } on FirebaseAuthException catch (e) {
      return e.message ?? '로그인에 실패했습니다.';
    }
  }


  //회원가입
  Future<String> registerUser(
      String email, String password, String name, String profileImageUrl) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = _auth.currentUser;

      await user?.updateDisplayName(name);
      await user?.updatePhotoURL(profileImageUrl);

      await user?.reload();
      user = _auth.currentUser;

      // Firestore에 사용자 정보 저장
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'profileimage': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return '회원가입이 완료되었습니다.';
    } on FirebaseAuthException catch (e) {
      return e.message ?? '회원가입에 실패했습니다.';
    }
  }

  // 로그아웃 메서드
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("로그아웃 중 오류 발생: $e");
      rethrow; // 오류 다시 던지기
    }
  }

  // 현재 로그인한 사용자 UID 가져오기
  String? getCurrentUserUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;  // 사용자가 로그인한 경우 UID 반환, 아니면 null 반환
  }

  // 현재 로그인된 사용자 정보
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  // Firestore에 사용자 데이터 저장
  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    if (userId.isEmpty || data.isEmpty) {
      throw ArgumentError("사용자 ID 또는 데이터가 비어 있을 수 없습니다.");
    }
    try {
      await _firestore.collection('users').doc(userId).set(data);
    } catch (e) {
      print("사용자 데이터 저장 중 오류 발생: $e");
      throw e; // 오류 다시 던지기
    }
  }

  // Firestore에서 사용자 데이터 가져오기
  Future<DocumentSnapshot> getUserData(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError("사용자 ID는 비어 있을 수 없습니다.");
    }
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print("사용자 데이터 가져오기 중 오류 발생: $e");
      throw e; // 오류 다시 던지기
    }
  }

  // 프로필 이미지 URL 가져오기
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return data['profileimage'];  // Firestore에서 저장된 프로필 이미지 URL 가져오기
      }
      return null;  // 이미지 URL이 없으면 null 반환
    } catch (e) {
      print("프로필 이미지 가져오기 오류: $e");
      return null;  // 오류 발생 시 null 반환
    }
  }

  // Firestore에 프로필 이미지 URL 저장하기
  Future<void> updateProfileImageUrl(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileimage': imageUrl,  // Firestore에 프로필 이미지 URL 저장
      });
    } catch (e) {
      print("프로필 이미지 URL 저장 오류: $e");
    }
  }

  // 선택한 이미지를 Firebase Storage에 업로드하고 Firestore에 URL 저장
  Future<void> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Firebase Storage에 이미지 업로드
      final storageRef = _storage.ref().child('profile_images/$userId.jpg');
      await storageRef.putFile(imageFile);

      // 업로드된 이미지의 다운로드 URL 가져오기
      final imageUrl = await storageRef.getDownloadURL();

      // Firestore에 다운로드 URL 저장
      await updateProfileImageUrl(userId, imageUrl);
    } catch (e) {
      print("프로필 이미지 업로드 오류: $e");
    }
  }



  // FCM 토큰 가져오기 (Firebase Cloud Messaging)
  Future<String?> getFCMToken() async {
    try {
      // FCM 토큰을 가져오는 예시, 나중에 푸시 알림 처리 등을 추가할 수 있음
      final token = await _auth.currentUser?.getIdToken();
      return token;
    } catch (e) {
      print("FCM 토큰 가져오기 중 오류 발생: $e");
      throw e;
    }
  }
}
