import 'package:app_team2/data/models/post.dart';

class PostState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;
  final bool isSyncedWithServer; // 동기화 상태 추가
  final bool isUpdateCaption; // 캡션 수정 상태 추가

  PostState({
    required this.posts,
    this.isLoading = false,
    this.error,
    this.isSyncedWithServer = true,
    this.isUpdateCaption = false,
  });

  PostState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
    bool? isSyncedWithServer,
    bool? isUpdateCaption,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSyncedWithServer: isSyncedWithServer ?? this.isSyncedWithServer,
      isUpdateCaption: isUpdateCaption ?? this.isUpdateCaption,
    );
  }
}
