import 'package:app_team2/providers/network/network_providers.dart';
import 'package:app_team2/providers/network/network_status_ui_provider.dart';
import 'package:app_team2/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/post/post_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // 새로고침 시 데이터 재로딩
  Future<void> _onRefresh(WidgetRef ref) async {
    final isOnline = ref.read(networkStateProvider).isOnline;

    if (isOnline) {
      // 네트워크가 연결되어 있으면 최신 데이터 가져오기
      ref.read(postProvider.notifier).subscribeToPostsCollection();
    } else {
      // 오프라인 상태에서는 캐시된 데이터 불러오기
      ref.read(postProvider.notifier).fetchCachedPosts();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 네트워크 상태 Provider 구독하고, TopNetworkBar에 context 전달
    ref.watch(networkStatusUiProvider)(context);

    // 게시물 상태 Provider 구독
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
        onRefresh: () => _onRefresh(ref),
        child: postState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : postState.error != null
                ? Center(
                    child: GestureDetector(
                      onTap: () => _onRefresh(ref),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('오류 발생: ${postState.error}'),
                          const SizedBox(height: 8),
                          const Text('새로고침하려면 탭하세요.'),
                        ],
                      ),
                    ),
                  )
                : postState.posts.isEmpty
                    ? const Center(child: Text('포스트가 없습니다.'))
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 8.0),
                        child: ListView.builder(
                          itemCount: postState.posts.length,
                          itemBuilder: (BuildContext context, int index) {
                            final post = postState.posts[index];
                            return GestureDetector(
                              onTap: () {
                                GoRouter.of(context).push(
                                  '/PostDetails',
                                  extra: post.postId,
                                );
                              },
                              child: PostCard(
                                post: post,
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
