import 'dart:io';

import 'package:app_team2/widgets/comment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app_team2/data/models/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/post/post_provider.dart';
import '../services/firebase_service.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  final PageController _controller = PageController();
  List<String> likes = [];
  final currentUserUid = FirebaseService().getCurrentUserUid();

  @override
  void initState() {
    super.initState();
    likes = List<String>.from(widget.post.likes);
  }

  Future<void> toggleLike(String postId) async {
    await FirebaseService().toggleLikePost(postId);
    setState(() {
      likes = List<String>.from(widget.post.likes);
    });
  }

  // 게시물 삭제 함수
  Future<void> _deletePost() async {
    try {
      // 삭제 확인 다이얼로그 표시
      final bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('게시물 삭제'),
          content: const Text('이 게시물을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (shouldDelete == true) {
        // PostNotifier를 통해 게시물 삭제
        await ref.read(postProvider.notifier).deletePost(widget.post.postId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('게시물이 삭제되었습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 삭제 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.post.userId == currentUserUid) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  '게시물 삭제',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('게시물 수정'),
                onTap: () {
                  // TODO: 게시물 수정 기능 구현
                  Navigator.pop(context);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('공유하기'),
              onTap: () {
                // TODO: 공유하기 기능 구현
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: FileImage(File(widget.post.profileImage)),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(widget.post.userName),
              const Spacer(),
              IconButton(
                onPressed: _showPostOptions,
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.post.imagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = widget.post.imagePaths[index];
              return FutureBuilder<bool>(
                future: File(imagePath).exists(), // 파일 존재 여부 확인
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(), // 로딩 인디케이터
                    );
                  } else if (snapshot.hasError || !snapshot.data!) {
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  } else {
                    return Image.file(
                      File(imagePath),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    );
                  }
                },
              );
            },
          ),
        ),
        if (widget.post.imagePaths.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: widget.post.imagePaths.length,
                effect: const WormEffect(
                  dotWidth: 8.0,
                  dotHeight: 8.0,
                  spacing: 16.0,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  toggleLike(widget.post.postId);
                },
                icon: Icon(
                  Icons.favorite,
                  color: likes.contains(currentUserUid) ? Colors.red : null,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => CommentDialog(
                          postId: widget.post.postId,
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment_outlined),
                  ),
                  Text(
                    widget.post.comments.length.toString(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${likes.length} likes',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${widget.post.userName}: ${widget.post.caption}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              Text(
                _getTimeAgo(widget.post.createdAt),
                style: const TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return '방금 전';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
