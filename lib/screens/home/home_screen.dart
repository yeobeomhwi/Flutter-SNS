import 'dart:async';

import 'package:app_team2/widgets/post_card.dart';
import 'package:app_team2/widgets/top_network_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/post/post_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    FCMtoken();
  }

  @override
  void dispose() {
    // 스트림 리스너 해제
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> FCMtoken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('=========fcmToken: $fcmToken');
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
    setState(() {
      _connectionStatus = result;
      // 와이파이나 모바일 네트워크가 연결되었으면
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile)) {
        TopNetworkBar.off(); // 상단 네트워크 바 숨김
        print('와이파이 또는 모바일 네트워크 연결됨');
        // 네트워크 연결 시 온라인 데이터 로드
      } else {
        print('인터넷 연결 없음');
        // 네트워크 연결 없음 시 상단에 네트워크 메시지 띄움
        TopNetworkBar.on(context);
        // 오프라인 데이터 로드
      }
    });
    // 연결 상태 출력
    print('Connectivity changed: $_connectionStatus');
  }

  @override
  Widget build(BuildContext context) {
    // postProvider에서 상태를 가져옵니다.
    final postState = ref.watch(postProvider);
    print('Current posts in state: ${postState.posts.length}');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tips_and_updates),
        ),
        title: const Text(
          'Feed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
        centerTitle: true,
      ),
      body: postState.isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 인디케이터
          : postState.error != null
              ? Center(child: Text('오류 발생: ${postState.error}')) // 오류 메시지
              : postState.posts.isEmpty
                  ? const Center(child: Text('포스트가 없습니다.')) // 포스트가 없을 때 메시지
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 8.0),
                      child: ListView.builder(
                        itemCount: postState.posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return PostCard(
                            post: postState.posts[index],
                          );
                        },
                      ),
                    ),
    );
  }
}
