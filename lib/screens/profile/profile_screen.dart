import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';  // 추가
import '../../services/firebase_service.dart';
import '../../widgets/infinity_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<void> _pickAndUploadImage(BuildContext context, String userId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      try {
        await FirebaseService().uploadProfileImage(userId, imageFile);
        setState(() {});
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
    // ScreenUtil 초기화
    ScreenUtil.init(context, designSize: Size(375, 812), minTextAdapt: true);

    final FirebaseService firebaseService = FirebaseService();
    final User? currentUser = firebaseService.getCurrentUser();

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('로그인된 사용자가 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 프로필 이미지
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(
                currentUser.photoURL ??
                    'https://firebasestorage.googleapis.com/v0/b/app-team2-2.firebasestorage.app/o/Default-Profile.png?alt=media&token=7da8bc98-ff57-491a-81a7-113b4a25cc62',
              ),
              radius: 100.w,
            ),

            SizedBox(height: 16.h),

            // 이름
            Text(
              '이름: ${currentUser.displayName ?? '이름 없음'}',
              style: TextStyle(fontSize: 18.sp),
            ),

            SizedBox(height: 16.h),

            // 이메일
            Text(
              '이메일: ${currentUser.email ?? '이메일 없음'}',
              style: TextStyle(fontSize: 18.sp),
            ),

            SizedBox(height: 16.h),

            //UID
            Text(
              'UID: ${currentUser.uid}',
              style: TextStyle(fontSize: 18.sp),
            ),

            SizedBox(height: 16.h),

            //구분선
            Padding(
              padding: EdgeInsets.all(16.w),  // flutter_screenutil 적용
              child: Divider(),
            ),

            //프로필사진 변경 버튼
            InfinityButton(
              onPressed: () => _pickAndUploadImage(context, currentUser.uid),
              title: '프로필 사진 변경',
            ),

            SizedBox(height: 5.h),  // flutter_screenutil 적용

            //로그아웃 버튼
            InfinityButton(
              onPressed: () async {
                try {
                  await FirebaseService().signOut();
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
