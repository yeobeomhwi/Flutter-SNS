import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((status) =>
      status.isNotEmpty &&
      (status.contains(ConnectivityResult.wifi) ||
          status.contains(ConnectivityResult.mobile)));
});
