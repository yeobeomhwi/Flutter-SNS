import 'dart:io';
import 'package:app_team2/providers/profile/profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../services/firebase_service.dart';
import '../../data/local/user_database_helper.dart';
import '../../data/models/usermodel.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState(isLoading: true));

  Future<void> loadUserData() async {
    try {
      state = ProfileState(isLoading: true);

      print('1');
      final firebaseUser = FirebaseService().getCurrentUser();
      if (firebaseUser == null) {
        state = ProfileState(error: '로그인된 사용자가 없습니다.');
        return;
      }
      print('2');
      final dbHelper = DatabaseHelper();
      String localPhotoURL = '이미지 없음';

      if (firebaseUser.photoURL != null) {
        print('3');
        final imageUrl = firebaseUser.photoURL!;
        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          final directory = await getApplicationDocumentsDirectory();
          final localImagePath = '${directory.path}/profile_picture.jpg';

          final file = File(localImagePath);
          await file.writeAsBytes(response.bodyBytes);

          localPhotoURL = localImagePath;
        } else {
          print('이미지 다운로드 실패: ${response.statusCode}');
        }
      }

      print('4');
      final newUser = UserModel(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? '이름 없음',
        email: firebaseUser.email ?? '이메일 없음',
        photoURL: localPhotoURL,
      );

      print('5');
      await dbHelper.insertUser(newUser);

      print('6');
      state = ProfileState(user: newUser);
    } catch (e) {
      state = ProfileState(error: '데이터 로드 실패: $e');
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
      state = ProfileState(user: updatedUser);  // 상태 업데이트
      print(state.user);
    } catch (e) {
      state = ProfileState(error: '이미지 저장 실패: $e');
    }
  }

  Future<void> updateProfilePicture(String userId, File imageFile) async {
    try {
      await FirebaseService().uploadProfileImage(userId, imageFile);

      // 캐시 비우기
      final imageProvider = FileImage(imageFile);
      await imageProvider.evict();

      await saveImageLocally(imageFile);


      // UI와 로컬 데이터 갱신
      await loadUserData();
    } catch (e) {
      state = ProfileState(error: '프로필 사진 업데이트 실패: $e');
    }
  }


}
