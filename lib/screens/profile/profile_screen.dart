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
  // 연결 상태를 저장하는 리스트
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // 연결 상태 변화 감지를 위한 스트림 리스너 등록
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
  }

  @override
  void dispose() {
    // 스트림 리스너 해제
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // 초기 연결 상태 확인
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity(); // 연결 상태 확인
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  // 연결 상태가 변경될 때마다 호출되는 함수
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    var uid = FirebaseService().getCurrentUser()?.uid;
    setState(() {
      _connectionStatus = result;
      // 와이파이나 모바일 네트워크가 연결되었으면
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile)) {
        TopNetworkBar.off(); // 상단 네트워크 바 숨김
        print('와이파이 또는 모바일 네트워크 연결됨');
        // 네트워크 연결 시 온라인 데이터 로드
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(profileProvider.notifier).loadUserDataOnline(uid);
        });
      } else {
        print('인터넷 연결 없음');
        // 네트워크 연결 없음 시 상단에 네트워크 메시지 띄움
        TopNetworkBar.on(context);
        // 오프라인 데이터 로드
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(profileProvider.notifier).loadUserDataOffline(uid);
        });
      }
    });
    // 연결 상태 출력
    print('Connectivity changed: $_connectionStatus');
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    // 프로필 로딩 중일 때 화면
    if (profileState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 에러가 있을 때 화면
    if (profileState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(child: Text(profileState.error!)),
      );
    }

    final user = profileState.user;

    // 프로필 이미지 갱신 처리
    final imageProvider = NetworkImage(user!.photoURL);
    imageProvider.evict().then((_) {
      setState(() {});
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: profileState.isLoading
            ? Center(child: CircularProgressIndicator()) // 로딩 중 스피너 표시
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 프로필 이미지 표시
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: FileImage(
                      File('${user.photoURL}'),
                    ),
                    radius: 100.w,
                  ),
                  SizedBox(height: 16.h),

                  // 사용자 이름 표시
                  Text(
                    '이름: ${user.displayName ?? '이름 없음'}',
                    style: TextStyle(fontSize: 18.sp),
                  ),

                  SizedBox(height: 16.h),

                  // 사용자 이메일 표시
                  Text(
                    '이메일: ${user.email ?? '이메일 없음'}',
                    style: TextStyle(fontSize: 18.sp),
                  ),

                  SizedBox(height: 16.h),

                  // 사용자 UID 표시
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

                  // 프로필 사진 변경 버튼
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

                  // 로그아웃 버튼
                  InfinityButton(
                    onPressed: () async {
                      try {
                        await FirebaseService().signOut(); // 로그아웃 처리
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
