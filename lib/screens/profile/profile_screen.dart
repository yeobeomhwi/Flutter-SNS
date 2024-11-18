import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../providers/profile/profile_proivder.dart';
import '../../services/firebase_service.dart';
import '../../widgets/infinity_button.dart';
import '../../widgets/top_network_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    var uid = FirebaseService().getCurrentUser()?.uid;
    setState(() {
      _connectionStatus = result;
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile)) {
        TopNetworkBar.off();
        print('와이파이 또는 모바일 네트워크 연결됨');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(profileProvider.notifier).loadUserDataOnline(uid);
        });
      } else {
        print('인터넷 연결 없음');
        // 상단에 토스트 메시지 띄우기
        TopNetworkBar.on(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(profileProvider.notifier).loadUserDataOffline(uid);
        });
      }
    });
    // ignore: avoid_print
    print('Connectivity changed: $_connectionStatus');
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

    // Profile image refresh handling
    final imageProvider = NetworkImage(user.photoURL);
    imageProvider.evict().then((_) {
      setState(() {});
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: profileState.isLoading
            ? Center(child: CircularProgressIndicator()) // 로딩 스피너 표시
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile image
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: FileImage(
                File('${user.photoURL}'),
              ),
              radius: 100.w,
            ),
            SizedBox(height: 16.h),

            // Name
            Text(
              '이름: ${user.displayName ?? '이름 없음'}',
              style: TextStyle(fontSize: 18.sp),
            ),

            SizedBox(height: 16.h),

            // Email
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

            // Divider
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Divider(),
            ),

            // Change profile picture button
            InfinityButton(
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile =
                await picker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  final imageFile = File(pickedFile.path);
                  ref
                      .read(profileProvider.notifier)
                      .updateProfilePicture(user.uid, imageFile);
                }
              },
              title: '프로필 사진 변경',
            ),

            SizedBox(height: 5.h),

            // Logout button
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
