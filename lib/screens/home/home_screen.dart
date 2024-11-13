import 'package:app_team2/data/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user.dart';
import '../../widgets/post_card.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final List<String> posts = List.generate(6, (index) => 'Post #$index');

  @override
  Widget build(BuildContext context, WidgetRef ref) {

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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext context, int index) {
            const user = User(
              id: '1',
              name: '닉네임',
              profileImage: 'https://picsum.photos/250/250?3',
            );
            final post = Post(
              id: '1',
              user: user,
              imageUrls: [
                'https://picsum.photos/250/250?1',
                'https://picsum.photos/250/250?2',
              ],
              caption: 'This is a post caption',
              createdAt: DateTime.now(),
              likesCount: 42,
              commentsCount: 7,
              isLiked: false,
            );
            return PostCard(post: post);
          },
        ),
      ),
    );
  }
}
