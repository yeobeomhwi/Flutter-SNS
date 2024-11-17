import 'dart:async';

import 'package:app_team2/data/models/post.dart';
import 'package:app_team2/providers/post_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostNotifier extends StateNotifier<PostState> {
  final FirebaseFirestore _firestore;

  PostNotifier(this._firestore) : super(PostState(posts: [])) {
    _subscribeToPostsCollection();
  }

  StreamSubscription<QuerySnapshot>? _subscription;

  void _subscribeToPostsCollection() {
    state = state.copyWith(isLoading: true);

    _subscription = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final posts = snapshot.docs.map((doc) {
          final data = doc.data();
          return Post(
            postId: doc.id,
            userId: data['userId'] as String,
            userName: data['userName'] as String,
            profileImage: data['profileImage'] as String,
            imageUrls: List<String>.from(data['imageUrls'] as List),
            caption: data['caption'] as String,
            createdAt: (data['createdAt'] as Timestamp).toDate(),
            likes: List<String>.from(data['likes'] as List),
            comments: List<Map<String, dynamic>>.from(data['comments'] as List),
          );
        }).toList();

        state = state.copyWith(posts: posts, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(error: error.toString(), isLoading: false);
      },
    );
  }

  Future<void> addPost({
    required String userId,
    required String userName,
    required String profileImage,
    required List<String> imageUrls,
    required String caption,
  }) async {
    try {
      final newPost = {
        'userId': userId,
        'userName': userName,
        'profileImage': profileImage,
        'imageUrls': imageUrls,
        'caption': caption,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
        'comments': [],
      };

      await _firestore.collection('posts').add(newPost);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) return;

      final likes = List<String>.from(postDoc.data()?['likes'] as List);

      if (likes.contains(userId)) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    try {
      final commentData = {
        'userId': userId,
        'userName': userName,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([commentData])
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
