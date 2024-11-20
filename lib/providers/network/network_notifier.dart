// 네트워크 상태 관리를 위한 NotifierProvider
import 'dart:async';
import 'package:app_team2/providers/network/network_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class NetworkStateNotifier extends StateNotifier<NetworkConnectionState> {
  NetworkStateNotifier() : super(NetworkConnectionState()) {
    initConnectivity();
  }

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // 초기 연결 상태 확인
  Future<void> initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);

      // 연결 상태 변화 감지를 위한 스트림 리스너 등록
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
    }
  }

  // 연결 상태 업데이트
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    final isOnline = result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile);

    state = state.copyWith(
      isOnline: isOnline,
      connectionStatus: result,
    );

    // 연결 상태 출력
    developer.log('Connectivity changed: $result');
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
