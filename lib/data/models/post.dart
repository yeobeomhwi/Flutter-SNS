class Post {
  final String postId;
  final String userId;
  final String userName;
  final String profileImage;
  final List<String> imagePaths;
  final String caption;
  final DateTime createdAt;
  final List<String> likes;
  final List<Map<String, dynamic>> comments;

  const Post({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.profileImage,
    required this.imagePaths,
    required this.caption,
    required this.createdAt,
    required this.likes,
    required this.comments,
  });

  Post copyWith({
    String? postId,
    String? userId,
    String? userName,
    String? profileImage,
    List<String>? imagePaths,
    String? caption,
    DateTime? createdAt,
    List<String>? likes,
    List<Map<String, dynamic>>? comments,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      profileImage: profileImage ?? this.profileImage,
      imagePaths: imagePaths ?? this.imagePaths,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}
