import 'dart:io';
import 'package:app_team2/providers/profile/profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../services/firebase_service.dart';
import '../../data/local/user_database_helper.dart';
import '../../data/models/usermodel.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState(isLoading: true));

  // 인터넷 연결이 있을 때 사용자 데이터 로드
  Future<void> loadUserDataOnline(String? uid) async {
    try {
      final firebaseUser = FirebaseService().getCurrentUser();
      if (firebaseUser == null) {
        state = ProfileState(error: '로그인된 사용자가 없습니다.');
        return;
      }

      final dbHelper = DatabaseHelper();
      String localPhotoURL = '이미지 없음';

      if (firebaseUser.photoURL != null) {
        final imageUrl = firebaseUser.photoURL!;
        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          final directory = await getApplicationDocumentsDirectory();
          final localImagePath = '${directory.path}/profile_picture.jpg';

          final file = File(localImagePath);
          await file.writeAsBytes(response.bodyBytes);

          localPhotoURL = localImagePath;
          print('localPhotoURL: $localPhotoURL');
        } else {
          print('이미지 다운로드 실패: ${response.statusCode}');
        }
      }

      final newUser = UserModel(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? '이름 없음',
        email: firebaseUser.email ?? '이메일 없음',
        photoURL: localPhotoURL,
      );

      await dbHelper.insertUser(newUser);
      state = ProfileState(user: newUser);
    } catch (e) {
      state = ProfileState(error: '데이터 로드 실패: $e');
      print('에러: $e');
    }
  }

  // 인터넷 연결이 없을 때 로컬 데이터 로드
  Future<void> loadUserDataOffline(String? uid) async {
    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUser(uid!);
      if (user != null) {
        state = ProfileState(user: user);
      } else {
        state = ProfileState(error: '로컬 사용자 데이터가 없습니다.');
      }
    } catch (e) {
      state = ProfileState(error: '로컬 데이터 로드 실패: $e');
      print('에러: $e');
    }
  }

  Future<void> saveImageLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/profile_picture.jpg';

      await imageFile.copy(filePath);

      final updatedUser = state.user?.copyWith(photoURL: filePath);
      print('=======데이터 변경 : $updatedUser');

      final dbHelper = DatabaseHelper();
      if (updatedUser != null) {
        await dbHelper.updateUser(updatedUser);
      }

      // 상태를 갱신하여 UI에 반영
      state = ProfileState(user: updatedUser); // 상태 업데이트
      print(state.user);
    } catch (e) {
      state = ProfileState(error: '이미지 저장 실패: $e');
    }
  }

  Future<void> updateProfilePicture(String userId, File imageFile) async {
    try {
      // 로딩 상태로 변경
      state = ProfileState(isLoading: true, user: state.user); // 로딩 시작

      // Firebase에 이미지 업로드
      await FirebaseService().uploadProfileImage(userId, imageFile);

      // 캐시 비우기 (이미지가 변경되었을 때 UI에서 반영하도록)
      final imageProvider = FileImage(imageFile);
      await imageProvider.evict();

      // 로컬 저장소에 이미지 파일 저장
      await saveImageLocally(imageFile);

      // 프로필 정보를 로컬 DB에 업데이트
      final updatedUser = state.user?.copyWith(photoURL: imageFile.path);
      if (updatedUser != null) {
        final dbHelper = DatabaseHelper();
        await dbHelper.updateUser(updatedUser);

        // 상태 갱신하여 UI 반영
        state = ProfileState(user: updatedUser); // 로딩 끝, 프로필 업데이트
      }
    } catch (e) {
      // 에러 발생 시 상태 업데이트
      state = ProfileState(isLoading: false, error: '프로필 사진 업데이트 실패: $e');
      print('에러: $e');
    }
  }

  // displayName 업데이트 함수 추가
  Future<void> updateDisplayName(String name) async {
    try {
      // 로딩 상태로 변경
      state = ProfileState(isLoading: true, user: state.user); // 로딩 시작
      final FirebaseAuth _auth = FirebaseAuth.instance;
      // Firebase에서 displayName 업데이트
      User? user = _auth.currentUser;
      // 사용자 정보 업데이트
      await user?.updateDisplayName(name);

      // 로컬 DB에 사용자 정보 업데이트
      final updatedUser = state.user?.copyWith(displayName: name);
      if (updatedUser != null) {
        final dbHelper = DatabaseHelper();
        await dbHelper.updateUser(updatedUser);

        // 상태 갱신하여 UI 반영
        state = ProfileState(user: updatedUser); // 로딩 끝, 프로필 업데이트
      }
    } catch (e) {
      // 에러 발생 시 상태 업데이트
      state = ProfileState(isLoading: false, error: 'displayName 업데이트 실패: $e');
      print('에러: $e');
    }
  }
}
