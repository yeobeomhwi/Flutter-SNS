import 'package:app_team2/providers/network/network_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_team2/providers/network/network_state.dart';
import 'package:app_team2/providers/post/post_provider.dart';
import 'package:app_team2/widgets/top_network_bar.dart'; // 파일명도 변경 필요

final networkStatusUiProvider = Provider((ref) {
  return (BuildContext context) {
    ref.listen<NetworkConnectionState>(
      networkStateProvider,
      (previous, next) {
        if (next.isOnline) {
          _handleOnlineState(ref);
        } else {
          _handleOfflineState(context, ref);
        }
      },
    );
  };
});

void _handleOnlineState(ProviderRef ref) {
  NetworkStatusBar.hide(); // off() 대신 hide() 사용
  ref.read(postProvider.notifier).subscribeToPostsCollection();
}

void _handleOfflineState(BuildContext context, ProviderRef ref) {
  NetworkStatusBar.show(
    // on() 대신 show() 사용
    context,
    message: "인터넷 연결 안됨",
  );
  ref.read(postProvider.notifier).fetchCachedPosts();
}
