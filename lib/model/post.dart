import 'package:app_team2/model/user.dart';
import 'package:app_team2/providers/picked_images_provider.dart';
import 'package:app_team2/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Post {
  final String id;
  final User user;
  final List<String> imageUrls;
  final String caption;
  final DateTime createdAt;
  final bool isLiked;
  final int likesCount;
  final Map<String, String>? comments; 
  final int commentsCount;

  const Post({
    required this.id,
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
    String? id,
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
      id: id ?? this.id,
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

  static Future<void> createPost(
      WidgetRef ref, 
      TextEditingController captionController, 
      FirebaseService firebaseService) async {
    final pickedImages = ref.read(pickedImagesProvider);
    final List<String> imagePaths = pickedImages.map((xFile) => xFile.path).toList();
    
    final userId = firebaseService.getCurrentUserUid();
    if (userId == null) throw Exception('로그인이 필요합니다');
    
    final userData = await firebaseService.getUserData(userId);
    final userDoc = userData.data() as Map<String, dynamic>;
    
    final currentUser = User(
      id: userId,
      name: userDoc['name'],
      profileImage: 'https://picsum.photos/250/250?3', 
    );


    final postRef = FirebaseFirestore.instance.collection('posts').doc();

    final newPost = Post(
      id: postRef.id, // 자동 생성된 ID 사용
      user: currentUser,
      imageUrls: imagePaths,
      caption: captionController.text,
      createdAt: DateTime.now(),
      isLiked: false,
      likesCount: 0,
      comments: null,
      commentsCount: 0,
    );

    await FirebaseFirestore.instance.collection('posts').add({
      'id': newPost.id,
      'userId': newPost.user.id,
      'imageUrls': newPost.imageUrls,
      'caption': newPost.caption,
      'createdAt': newPost.createdAt.toIso8601String(),
      'isLiked': newPost.isLiked,
      'likesCount': newPost.likesCount,
      'comments': newPost.comments,
      'commentsCount': newPost.commentsCount,
    });
  }
}
