import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image/image.dart' as img;

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

  Future<String> registerUser(String email, String password, String name,
      String profileImageUrl) async {
    try {
      // 이메일 중복 확인
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);

      // 이미 이메일이 존재하면 로그인 처리하거나 오류 메시지 반환
      if (signInMethods.isNotEmpty) {
        return '이미 존재하는 이메일입니다. 로그인해주세요.';
      }

      // 이메일이 존재하지 않으면 회원가입
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = _auth.currentUser;

      // 사용자 정보 업데이트
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

      return '회원가입이 완료되었습니다.'; // 성공 메시지
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return '이미 존재하는 이메일입니다. 로그인해주세요.';
      }
      return e.message ?? '회원가입에 실패했습니다.'; // 다른 오류 처리
    }
  }

  // 로그아웃 메서드
  Future<void> signOut() async {
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

      print(imageUrl);
      // Firestore에 다운로드 URL 저장
      await updateProfileImageUrl(userId, imageUrl);
    } catch (e) {
      print("프로필 이미지 업로드 오류: $e");
    }
  }

// FCM 토큰 가져오기 (Firebase Cloud Messaging)
  Future<String?> getFCMToken() async {
    try {
      // 현재 사용자의 Firebase ID Token을 가져옵니

      final fcmToken = await FirebaseMessaging.instance.getToken();
      // ID Token을 Firebase Firestore에 fcmTokens로 저장합니다
      if (fcmToken != null) {
        await _saveFCMTokenToFirestore(fcmToken);
      }

      return fcmToken;
    } catch (e) {
      print("FCM 토큰 가져오기 중 오류 발생: $e");
      rethrow;
    }
  }

  // FCM 토큰을 Firestore에 저장하는 함수
  Future<void> _saveFCMTokenToFirestore(String fcmToken) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        print("사용자가 로그인되지 않았습니다.");
        return;
      }

      // users/{uid} 문서에 fcmTokens 배열 필드로 FCM 토큰 추가
      final userRef = _firestore.collection('users').doc(uid);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        // 기존에 FCM 토큰이 있는 경우 배열에 추가
        await userRef.update({
          'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        });
      } else {
        // 사용자 문서가 없으면 새로 생성
        await userRef.set({
          'fcmTokens': [fcmToken],
        });
      }

      print("FCM 토큰 Firestore에 저장 완료.");
    } catch (e) {
      print("FCM 토큰을 Firestore에 저장하는 중 오류 발생: $e");
      rethrow;
    }
  }


  // 게시물 문구 수정
  Future<void> updatePostCaption(String postId, String newCaption) async {
    try {
      // postId 유효성 검사
      if (postId.isEmpty) {
        throw ArgumentError('게시물 ID가 비어있습니다.');
      }

      // 현재 사용자가 해당 게시물의 작성자인지 확인
      final postDoc = await _firestore.collection('posts').doc(postId).get();

      if (!postDoc.exists) {
        throw Exception('존재하지 않는 게시물입니다.');
      }

      final postData = postDoc.data() as Map<String, dynamic>;
      final postUserId = postData['userId'];
      final currentUserId = getCurrentUserUid();

      if (postUserId != currentUserId) {
        throw Exception('게시물 수정 권한이 없습니다.');
      }

      // Firestore에서 캡션 업데이트
      await _firestore.collection('posts').doc(postId).update({
        'caption': newCaption,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('게시물 캡션 수정 중 오류 발생: $e');
      rethrow;
    }
  }

  //좋아요 기능
  Future<void> toggleLikePost(String? postId) async {
    try {
      // postId가 null인 경우 함수 종료
      if (postId == null) {
        print("postId가 null입니다!");
        return;
      }

      // Firestore에서 포스트 문서 가져오기
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      // 문서가 존재하는지 확인
      if (!postDoc.exists) {
        print("문서가 존재하지 않습니다!");
        return; // 문서가 존재하지 않으면 함수 종료
      }
      var uid = getCurrentUser()?.uid;
      // 좋아요 배열 가져오기
      List<String> Likes = List<String>.from(postDoc['likes'] ?? []);

      // 사용자가 좋아요를 클릭하면
      if (Likes.contains(uid)) {
        // 이미 좋아요를 눌렀다면 좋아요 취소
        Likes.remove(uid);
      } else {
        // 좋아요를 눌렀다면 좋아요 추가
        Likes.add(uid!);
      }

      // Firestore에 업데이트된 좋아요 배열 저장
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': Likes,
      });
    } catch (e) {
      print("좋아요 토글 중 에러 발생: $e");
    }
  }

  //notifications 테이블 생성
  Future<void> CreateNotificationsTable() async {
    // Firestore에서 해당 문서 가져오기
    print('==================uid ${_auth.currentUser?.uid}');
    var docRef =
        _firestore.collection('notifications').doc(_auth.currentUser?.uid);
    var docSnapshot = await docRef.get();

    // 문서가 존재하지 않으면 새로 생성
    if (!docSnapshot.exists) {
      await docRef.set({
        'messages': [],
      });
      print("새로운 알림 테이블이 생성되었습니다.");
    } else {
      print("알림 테이블이 이미 존재합니다.");
    }
  }

}
