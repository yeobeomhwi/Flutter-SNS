import 'package:app_team2/data/models/post.dart';
import 'package:app_team2/data/repositories/post_repository.dart';
import 'package:app_team2/providers/post_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostNotifier extends StateNotifier<PostState> {
  final PostRepository _postRepository;

  PostNotifier(this._postRepository) : super(PostState(posts: [])) {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      state = state.copyWith(isLoading: true);
      final posts = await _postRepository.getAllPosts();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addPost({
    required String userId,
    required String userName,
    required String profileImage,
    required List<String> imagePaths,
    required String caption,
  }) async {
    try {
      final newPost = Post(
        postId: DateTime.now().millisecondsSinceEpoch.toString(), // 고유 ID 생성
        userId: userId,
        userName: userName,
        profileImage: profileImage,
        imagePaths: imagePaths,
        caption: caption,
        createdAt: DateTime.now(),
        likes: [],
        comments: [],
      );

      await _postRepository.savePost(newPost);
      await _loadPosts(); // 포스트 목록 새로고침
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _postRepository.deletePost(postId);
      await _loadPosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final post = await _postRepository.getPostById(postId);
      if (post == null) return;

      List<String> updatedLikes = List.from(post.likes);
      if (updatedLikes.contains(userId)) {
        updatedLikes.remove(userId);
      } else {
        updatedLikes.add(userId);
      }

      final updatedPost = post.copyWith(likes: updatedLikes);
      await _postRepository.updatePost(updatedPost);
      await _loadPosts();
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
      final post = await _postRepository.getPostById(postId);
      if (post == null) return;

      final commentData = {
        'commentId': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': userId,
        'userName': userName,
        'comment': comment,
        'createdAt': DateTime.now().toIso8601String(),
      };

      List<Map<String, dynamic>> updatedComments = List.from(post.comments);
      updatedComments.add(commentData);

      final updatedPost = post.copyWith(comments: updatedComments);
      await _postRepository.updatePost(updatedPost);
      await _loadPosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final post = await _postRepository.getPostById(postId);
      if (post == null) return;

      List<Map<String, dynamic>> updatedComments = List.from(post.comments);
      updatedComments
          .removeWhere((comment) => comment['commentId'] == commentId);

      final updatedPost = post.copyWith(comments: updatedComments);
      await _postRepository.updatePost(updatedPost);
      await _loadPosts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
