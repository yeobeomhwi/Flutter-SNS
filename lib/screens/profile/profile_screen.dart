import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/infinity_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAndUploadImage(BuildContext context, String userId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // Firebase Storage에 이미지 업로드
      try {
        await FirebaseService().uploadProfileImage(userId, imageFile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 사진이 변경되었습니다.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseService().getCurrentUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: currentUser == null
            ? const Text('로그인된 사용자가 없습니다.')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(currentUser.photoURL ??
                  'https://firebasestorage.googleapis.com/v0/b/app-team2-2.firebasestorage.app/o/Default-Profile.png?alt=media&token=7da8bc98-ff57-491a-81a7-113b4a25cc62'),
              radius: 100,
            ),
            const SizedBox(height: 16),
            Text(
              '이름: ${currentUser.displayName ?? '이름 없음'}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '이메일: ${currentUser.email ?? '이메일 없음'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'UID: ${currentUser.uid}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'providerID: ${currentUser.providerData.isNotEmpty ? currentUser.providerData[0].providerId : '데이터 없음'}',
              style: const TextStyle(fontSize: 18),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Divider(),
            ),
            InfinityButton(
              onPressed: () => _pickAndUploadImage(context, currentUser.uid),
              title: '프로필 사진 변경',
            ),
            const SizedBox(height: 5),
            InfinityButton(
              onPressed: () async {
                try {
                  await FirebaseService.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그아웃 되었습니다.')),
                  );
                  GoRouter.of(context).push('/Login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그아웃 실패: $e')),
                  );
                }
              },
              title: '로그아웃',
            ),
          ],
        ),
      ),
    );
  }
}
