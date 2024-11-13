import 'package:app_team2/model/user.dart';
import 'package:app_team2/providers/picked_images_provider.dart';
import 'package:app_team2/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class Post {
  final String id;
  final User user;
  final List<String> imageUrls;
  final String caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  const Post({
    required this.id,
    required this.user,
    required this.imageUrls,
    required this.caption,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  Post copyWith({
    String? id,
    User? user,
    List<String>? imageUrls,
    String? caption,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
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
      username: userDoc['name'],
      avatarUrl: 'https://picsum.photos/250/250?3',
    );

    final newPost = Post(
      id: const Uuid().v4(),
      user: currentUser,
      imageUrls: imagePaths,
      caption: captionController.text,
      createdAt: DateTime.now(),
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
    );

    await FirebaseFirestore.instance.collection('posts').add({
      'id': newPost.id,
      'userId': newPost.user.id,
      'imageUrls': newPost.imageUrls,
      'caption': newPost.caption,
      'createdAt': newPost.createdAt.toIso8601String(),
      'likesCount': newPost.likesCount,
      'commentsCount': newPost.commentsCount,
      'isLiked': newPost.isLiked,
    });
  }
}
