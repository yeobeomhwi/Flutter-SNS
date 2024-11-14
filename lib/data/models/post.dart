class Post {
  final String postId;
  final String userId; // userId 추가
  final String name; // 사용자 이름 추가
  final String profileImage; // 사용자 프로필 이미지 추가
  final List<String> imageUrls;
  final String caption;
  final DateTime createdAt;
  final bool isLiked;
  final int likesCount;
  final Map<String, String>? comments;
  final int commentsCount;

  const Post({
    required this.postId,
    required this.userId, // userId 필드 추가
    required this.name, // name 필드 추가
    required this.profileImage, // profileImage 필드 추가
    required this.imageUrls,
    required this.caption,
    required this.createdAt,
    this.isLiked = false,
    this.likesCount = 0,
    this.comments,
    this.commentsCount = 0,
  });

  // factory constructor를 사용하여 userId로 사용자 정보를 설정
  factory Post.fromUserId(
      String postId,
      String userId,
      String name,
      String profileImage,
      List<String> imageUrls,
      String caption,
      DateTime createdAt) {
    return Post(
      postId: postId,
      userId: userId,
      name: name,
      profileImage: profileImage,
      imageUrls: imageUrls,
      caption: caption,
      createdAt: createdAt,
    );
  }

  Post copyWith({
    String? postId,
    String? userId,
    String? name,
    String? profileImage,
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
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
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
