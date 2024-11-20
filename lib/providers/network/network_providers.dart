import 'package:flutter_riverpod/flutter_riverpod.dart';

// 연결 상태 enum
class NetworkConnectionState {
   late final bool isOnline;
   NetworkConnectionState({this.isOnline = true});
}

// 연결 상태 관리를 위한 StateProvider
final connectionStateProvider = StateProvider<NetworkConnectionState>((ref) {
  return NetworkConnectionState();
});
