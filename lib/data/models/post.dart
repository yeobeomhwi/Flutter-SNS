class Post {
  final String postId;
  final String userId;
  final String userName;
  final String profileImage;
  final List<String> imageUrls;
  final String caption;
  final dynamic createdAt;  // Change this to dynamic to handle Firestore FieldValue
  final List<String> likes;
  final List<Map<String, dynamic>> comments;
  final bool isSynced;

  const Post({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.profileImage,
    required this.imageUrls,
    required this.caption,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.isSynced,
  });

  // Copy method remains the same
  Post copyWith({
    String? postId,
    String? userId,
    String? userName,
    String? profileImage,
    List<String>? imageUrls,
    String? caption,
    dynamic createdAt,  // Accept dynamic type here as well
    List<String>? likes,
    List<Map<String, dynamic>>? comments,
    bool? isSynced,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      profileImage: profileImage ?? this.profileImage,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  factory Post.fromMap(Map<String, dynamic> data) {
    return Post(
      postId: data['postId'] as String,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      profileImage: data['profileImage'] as String,
      imageUrls: List<String>.from(data['imageUrls'] as List),
      caption: data['caption'] as String,
      createdAt: data['createdAt'], // Handle Timestamp or FieldValue here
      likes: List<String>.from(data['likes'] as List),
      comments: List<Map<String, dynamic>>.from(data['comments'] as List),
      isSynced: data['isSynced'] as bool, // Map isSynced from Firestore document
    );
  }

}
