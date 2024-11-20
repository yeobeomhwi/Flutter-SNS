import 'package:app_team2/providers/post/post_provider.dart';
import 'package:app_team2/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailsScreen extends ConsumerWidget {
  final String postId;
  const PostDetailsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 게시물 상태 Provider 구독
    final postState = ref.watch(postProvider);

    // postId와 일치하는 post 찾기
    final post = postState.posts.firstWhere(
      (post) => post.postId == postId,
      orElse: () => throw Exception('포스트를 찾을 수 없습니다'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '포스트 상세페이지',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PostCard(post: post),
            ],
          ),
        ),
      ),
    );
  }
}
