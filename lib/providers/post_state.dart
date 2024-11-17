import 'package:app_team2/data/models/post.dart';

class PostState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  PostState({
    required this.posts,
    this.isLoading = false,
    this.error,
  });

  PostState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
