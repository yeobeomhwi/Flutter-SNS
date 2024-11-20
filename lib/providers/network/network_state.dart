import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectionState {
  final bool isOnline;
  final List<ConnectivityResult> connectionStatus;

  NetworkConnectionState({
    this.isOnline = true,
    this.connectionStatus = const [ConnectivityResult.none],
  });

  NetworkConnectionState copyWith({
    bool? isOnline,
    List<ConnectivityResult>? connectionStatus,
  }) {
    return NetworkConnectionState(
      isOnline: isOnline ?? this.isOnline,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }
}
