import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  // 이메일 로그인
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("로그인 중 오류 발생: ${e.message}");
      throw FirebaseAuthException(
          code: e.code, message: e.message); // 오류 다시 던지기
    }
  }

  // 구글 로그인
  Future<String> signInWithGoogle() async {
    try {
      // 구글 인증 흐름 시작
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // 인증 정보를 가져옴

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Firebase 인증 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Firebase로 로그인
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      // Firestore에서 사용자 문서 확인 및 새 사용자일 경우 추가
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

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
  Future<String> registerUser(String email, String password, String name,
      String profileImageUrl) async {
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
    return user?.uid; // 사용자가 로그인한 경우 UID 반환, 아니면 null 반환
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
      rethrow; // 오류 다시 던지기
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
      rethrow; // 오류 다시 던지기
    }
  }

  // 프로필 이미지 URL 가져오기
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return data['profileimage']; // Firestore에서 저장된 프로필 이미지 URL 가져오기
      }
      return null; // 이미지 URL이 없으면 null 반환
    } catch (e) {
      print("프로필 이미지 가져오기 오류: $e");
      return null; // 오류 발생 시 null 반환
    }
  }

  // Firestore에 프로필 이미지 URL 저장하기
  Future<void> updateProfileImageUrl(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileimage': imageUrl, // Firestore에 프로필 이미지 URL 저장
      });
      final user = getCurrentUser();
      await user?.updatePhotoURL(imageUrl);
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
      rethrow;
    }
  }

  // Firestore에 프로필 이미지 URL 저장하기
  Future<void> updatePostImageUrls(
      String postId, List<String> imageUrls) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'imageUrls': imageUrls, // Firestore에 프로필 이미지 URL 저장
      });
    } catch (e) {
      print("프로필 이미지 URL 저장 오류: $e");
    }
  }

  // create post에서 선택한 이미지 목록을 Firebase Storage에 업로드하고 Firestore에 URL 저장
  Future<List<String>?> uploadPostImages(
      String postId, List<File> imageFileList) async {
    try {
      final List<String> imageUrls = [];

      // 각각의 이미지에 대해 반복
      for (int i = 0; i < imageFileList.length; i++) {
        final imageFile = imageFileList[i];

        // Firebase Storage에 이미지 업로드
        final storageRef = _storage.ref().child('post_images/${postId}_$i.jpg');
        await storageRef.putFile(imageFile);

        // 업로드된 이미지의 다운로드 URL 가져오기
        final imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl); // URL을 리스트에 추가
      }

      // 모든 이미지 업로드가 완료된 후 Firestore에 URL 리스트 저장
      await updatePostImageUrls(postId, imageUrls);

      return imageUrls;
    } catch (e) {
      print("이미지 업로드 오류: $e");
    }
    return null;
  }

  // Firestore의 posts 컬렉션에 새로운 포스트 추가
  Future<void> createPost(
      String userId, String caption, List<File> imagePaths) async {
    try {
      // 현재 시간을 밀리세컨드로 가져오기
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final postId = '$userId$timestamp';

      // 사용자 정보를 가져오기
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('사용자를 찾을 수 없습니다.');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final String name = userData['name'];
      final String profileImage = userData['profileimage'] ?? '';
      final imageUrls = await uploadPostImages(postId, imagePaths);

      await _firestore.collection('posts').add({
        'postId': postId,
        'userId': userId, // 사용자 ID 추가
        'name': name, // 사용자 이름 추가
        'profileImage': profileImage, // 프로필 이미지 추가
        'caption': caption,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'isLiked': false,
        'likesCount': 0,
        'commentsCount': 0,
        'comments': {}, // 초기화된 댓글
      });
    } catch (e) {
      print("포스트 생성 중 오류 발생: $e");
      rethrow; // 오류 다시 던지기
    }
  }
}
