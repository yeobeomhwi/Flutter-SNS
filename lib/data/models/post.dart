import 'package:app_team2/data/models/user.dart';

class Post {
  final String postId;
  final User user;
  final List<String> imageUrls;
  final String caption;
  final DateTime createdAt;
  final bool isLiked;
  final int likesCount;
  final Map<String, String>? comments; 
  final int commentsCount;

  const Post({
    required this.postId,
    required this.user,
    required this.imageUrls,
    required this.caption,
    required this.createdAt,
    this.isLiked = false,
    this.likesCount = 0,
    this.comments, 
    this.commentsCount = 0,
  });

  Post copyWith({
    String? postId,
    User? user,
    List<String>? imageUrls,
    String? caption,
    DateTime? createdAt,
    bool? isLiked,
    int? likesCount,
    Map<String, String>? comments,
    int? commentsCount,
  }) {
    return Post(
      postId: postId ?? this.postId,
      user: user ?? this.user,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      likesCount: likesCount ?? this.likesCount,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
