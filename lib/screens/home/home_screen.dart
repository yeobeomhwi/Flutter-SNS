import 'package:app_team2/data/models/post.dart';
import 'package:app_team2/services/firebase_service.dart';
import 'package:app_team2/widgets/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 인디케이터
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}')); // 오류 처리
          }

          // Firestore에서 가져온 포스트 리스트
          final posts = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Post(
                postId: data['postId'],
                userId: data['userId'] ?? 'unknown',
                userName: data['userName'],
                profileImage: data['profileImage'],
                caption: data['caption'],
                imageUrls: List<String>.from(data['imageUrls']),
                createdAt: (data['createdAt'] as Timestamp).toDate(),
                likes: List<String>.from(data['likes'] ?? []),
                comments: List<Map<String, String>>.from(data['comments']));
          }).toList();

          // 포스트가 없을 경우 메시지 표시
          if (posts.isEmpty) {
            return const Center(child: Text('포스트가 없습니다.')); // 포스트가 없을 때 메시지
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                return PostCard(
                  post: posts[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
