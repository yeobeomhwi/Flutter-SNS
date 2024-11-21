import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:app_team2/layout/default_layout.dart';
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
        NetworkStatusBar.hide(); // 상단 네트워크 바 숨김
        print('와이파이 또는 모바일 네트워크 연결됨');
        // 네트워크 연결 시 온라인 데이터 로드
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(profileProvider.notifier).loadUserDataOnline(uid);
        });
      } else {
        print('인터넷 연결 없음');
        // 네트워크 연결 없음 시 상단에 네트워크 메시지 띄움
        NetworkStatusBar.show(context, message: "인터넷 연결 안됨");
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

    return DefaultLayout(
      title: '프로필',
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: profileState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30.h),

                      // 프로필 이미지 섹션
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            backgroundImage: FileImage(File(user.photoURL)),
                            radius: 80.w,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    final imageFile = File(pickedFile.path);
                                    ref
                                        .read(profileProvider.notifier)
                                        .updateProfilePicture(
                                            user.uid, imageFile);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      // 사용자 정보 섹션
                      Container(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          children: [
                            Text(
                              user.displayName ?? '이름 없음',
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const Divider(),
                            Text(
                              user.email ?? '이메일 없음',
                              style: TextStyle(
                                  fontSize: 16.sp, color: Colors.grey[700]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // 이름 변경 버튼
                      InfinityButton(
                        backgroundColor: Colors.grey,
                        onPressed: () => _showDisplayNameDialog(context),
                        title: '닉네임 변경',
                      ),

                      SizedBox(height: 5.h),

                      // 로그아웃 버튼
                      InfinityButton(
                        backgroundColor: Colors.grey,
                        onPressed: () async {
                          try {
                            await FirebaseService().signOut();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('로그아웃 되었습니다.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            GoRouter.of(context).push('/Login');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('로그아웃 실패: $e'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        title: '로그아웃',
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showDisplayNameDialog(BuildContext context) {
    final TextEditingController displayNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '닉네임 변경',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: displayNameController,
            decoration: const InputDecoration(
              labelText: '새로운 이름을 입력하세요',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return '이름을 입력해 주세요.';
              } else if (value.length < 3) {
                return '이름은 최소 3글자 이상이어야 합니다.';
              } else if (!_isValidName(value)) {
                return '유효한 이름을 입력해 주세요. 한글, 영어만 입력 가능합니다.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final name = displayNameController.text;
                ref.read(profileProvider.notifier).updateDisplayName(name);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('이름이 변경되었습니다: $name'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  bool _isValidName(String name) {
    final regExp = RegExp(r'^[a-zA-Z가-힣\s]+$');
    return regExp.hasMatch(name);
  }
}
