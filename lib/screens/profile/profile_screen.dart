import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FirebaseService에서 현재 로그인한 사용자 정보 가져오기
    final User? currentUser = FirebaseService().getCurrentUser();
    final String? currentUserUid = FirebaseService().getCurrentUserUid(); // UID 가져오기

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: currentUser == null
            ? const Text('로그인된 사용자가 없습니다.')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 구글 로그인 사용자는 사진이 있을 수 있음
            CircleAvatar(
              backgroundImage: NetworkImage(currentUser.photoURL ??
                  'https://firebasestorage.googleapis.com/v0/b/app-team2-2.firebasestorage.app/o/Default-Profile.png?alt=media&token=7da8bc98-ff57-491a-81a7-113b4a25cc62'),
              radius: 50,
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
            // UID 추가
            Text(
              'UID: ${currentUserUid ?? 'UID 없음'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
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
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
