import 'package:app_team2/data/models/post.dart';
import 'package:app_team2/widgets/post_card.dart';
import 'package:app_team2/providers/post_provider.dart'; // 추가
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // postProvider에서 상태를 가져옵니다.
    final postState = ref.watch(postProvider);

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
