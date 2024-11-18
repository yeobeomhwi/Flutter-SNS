import 'package:app_team2/widgets/post_card.dart';
import 'package:app_team2/providers/post_provider.dart'; // 추가
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
