import 'dart:async';

import 'package:app_team2/widgets/post_card.dart';
import 'package:app_team2/widgets/top_network_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/network/network_providers.dart';
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
    setState(() {
      _connectionStatus = result;
      // 와이파이나 모바일 네트워크가 연결되었으면
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile)) {
        //네트워크 상태
        ref.read(connectionStateProvider.notifier).state =
            NetworkConnectionState(isOnline: true);
        // 상단 네트워크 바 숨김
        TopNetworkBar.off();
        // 데이터 로딩
        ref.read(postProvider.notifier).subscribeToPostsCollection();
      } else {
        //네트워크 상태
        ref.read(connectionStateProvider.notifier).state =
            ref.read(connectionStateProvider.notifier).state =
            NetworkConnectionState(isOnline: false);
        //상단바
        TopNetworkBar.on(context);
        //데이터 로딩
        ref.read(postProvider.notifier).fetchCachedPosts();
      }
    });
    // 연결 상태 출력
    print('Connectivity changed: $_connectionStatus');
  }

  // 새로고침 시 데이터 재로딩
  Future<void> _onRefresh() async {
    // 네트워크 상태 확인 후 데이터를 다시 로드
    final isOnline = ref.read(connectionStateProvider.notifier).state.isOnline;

    if (isOnline) {
      // 네트워크가 연결되어 있으면 최신 데이터를 가져옵니다.
      ref.read(postProvider.notifier).subscribeToPostsCollection();
    } else {
      // 오프라인 상태에서는 캐시된 데이터를 불러옵니다.
      ref.read(postProvider.notifier).fetchCachedPosts();
    }
  }



  @override
  Widget build(BuildContext context) {
    // postProvider에서 상태를 가져옵니다.
    final postState = ref.watch(postProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              GoRouter.of(context).push('/Notifications');
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: postState.isLoading
            ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때 인디케이터
            : postState.error != null
            ? Center(
          child: GestureDetector(
            onTap: _onRefresh, // 오류 메시지를 탭하면 새로고침
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('오류 발생: ${postState.error}'), // 오류 메시지
                const SizedBox(height: 8),
                const Text('새로고침하려면 탭하세요.'), // 새로고침 안내 메시지
              ],
            ),
          ),
        )
            : postState.posts.isEmpty
            ? const Center(child: Text('포스트가 없습니다.')) // 포스트가 없을 때 메시지
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
          child: ListView.builder(
            itemCount: postState.posts.length,
            itemBuilder: (BuildContext context, int index) {
              return PostCard(
                post: postState.posts[index],
              );
            },
          ),
        ),
      ),
    );
  }
}
