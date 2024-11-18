import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../providers/profile/profile_proivder.dart';
import '../../services/firebase_service.dart';
import '../../widgets/infinity_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // 위젯 트리가 빌드된 후에 loadUserData() 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (profileState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(child: Text(profileState.error!)),
      );
    }

    final user = profileState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('사용자 정보를 찾을 수 없습니다.')),
      );
    }

    final imageProvider = FileImage(File(user.photoURL));
    imageProvider.evict().then((_) {
      setState(() {});
    });


    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 프로필 이미지
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: FileImage(
                File('${user.photoURL}'),
              ),
              radius: 100.w,
            ),



            SizedBox(height: 16.h),

            // 이름
            Text(
              '이름: ${user.displayName ?? '이름 없음'}',
              style: TextStyle(fontSize: 18.sp),
            ),

            SizedBox(height: 16.h),

            // 이메일
            Text(
              '이메일: ${user.email ?? '이메일 없음'}',
              style: TextStyle(fontSize: 18.sp),
            ),

            SizedBox(height: 16.h),

            // UID
            Text(
              'UID: ${user.uid}',
              style: TextStyle(fontSize: 18.sp),
            ),

            SizedBox(height: 16.h),

            // 구분선
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Divider(),
            ),

            // 프로필사진 변경 버튼
            InfinityButton(
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  final imageFile = File(pickedFile.path);
                  ref.read(profileProvider.notifier).updateProfilePicture(user.uid, imageFile);
                }
              },
              title: '프로필 사진 변경',
            ),

            SizedBox(height: 5.h),

            // 로그아웃 버튼
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
