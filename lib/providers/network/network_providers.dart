import 'package:app_team2/providers/network/network_notifier.dart';
import 'package:app_team2/providers/network/network_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkStateProvider =
    StateNotifierProvider<NetworkStateNotifier, NetworkConnectionState>((ref) {
  return NetworkStateNotifier();
});
