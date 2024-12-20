import 'dart:io';

import 'package:app_team2/core/icon_constant.dart';
import 'package:app_team2/widgets/comment_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app_team2/data/models/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/post/post_provider.dart';
import '../screens/home/post_details_screen.dart';
import '../services/firebase_service.dart';
import '../core/color_constant.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  final bool hideCommentButton;
  final bool isUpdateCaption;

  const PostCard({
    super.key,
    required this.post,
    this.hideCommentButton = false,
    this.isUpdateCaption = false,
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

  // 게시물 수정 함수
  void _updateCaption() {
    context.go('/UpdateCaption', extra: widget.post.postId);
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

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
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
                    Navigator.pop(context);
                    context.push('/UpdateCaption', extra: widget.post.postId);
                  },
                ),
              ],
              if (widget.post.userId != currentUserUid)
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    '내 게시물만 수정할 수 있습니다.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
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
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.post.profileImage,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child:
                        Icon(Icons.error_outline, size: 24, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(widget.post.userName),
              const Spacer(),
              IconButton(
                onPressed: () => _showPostOptions(context),
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.post.imageUrls.length,
            itemBuilder: (context, index) {
              // URL이 "http"로 시작하면 네트워크 이미지를 사용
              if (widget.post.imageUrls[index].startsWith('http')) {
                return CachedNetworkImage(
                  imageUrl: widget.post.imageUrls[index],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text(
                          '이미지 다운로드 중...',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  cacheKey: widget.post.imageUrls[index],
                );
              } else if (widget.post.imageUrls[index].startsWith('/data')) {
                // URL이 "/data"로 시작하면 로컬 파일에서 이미지 로드
                final imageFile = File(widget.post.imageUrls[index]);

                // 로컬 파일이 없으면 에러 메시지 처리
                if (!imageFile.existsSync()) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text(
                          '이미지 다운로드 중...',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // 파일이 존재하면 이미지 로드
                return Image.file(
                  imageFile,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                );
              } else {
                // 다른 경우 처리 (필요에 따라 수정 가능)
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        if (widget.post.imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: widget.post.imageUrls.length,
                effect: WormEffect(
                  dotWidth: 8.0,
                  dotHeight: 8.0,
                  spacing: 16.0,
                  activeDotColor: greenColor,
                  dotColor: Colors.grey.shade300,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  toggleLike(widget.post.postId);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    likes.contains(currentUserUid) ? heartSolid : heart,
                    color: likes.contains(currentUserUid)
                        ? const Color(0xffff0034)
                        : null,
                  ),
                ),
              ),
              Text(
                '${likes.length} likes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: likes.contains(currentUserUid)
                      ? const Color(0xffff0034)
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Row(
                children: [
                  if (!widget.hideCommentButton)
                    GestureDetector(
                      onTap: () {
                        // 댓글 모달 표시
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => CommentDialog(
                            postId: widget.post.postId,
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          conversationBubble,
                          size: 22,
                        ),
                      ),
                    ),
                  Text(
                    widget.post.comments.length.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
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
              const SizedBox(height: 4.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      widget.post.caption,
                      maxLines: 2,
                    ),
                  ),
                  if (widget.post.caption.length >
                      70) // 텍스트가 100자 이상일 때만 ...more 표시
                    GestureDetector(
                      onTap: () {
                        // 페이지 이동 로직
                        if (widget.post.postId.isNotEmpty) {
                          print(
                              'Tapped notification with postId: ${widget.post.postId}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailsScreen(postId: widget.post.postId),
                            ),
                          );
                        } else {
                          print('PostId is empty!');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('유효하지 않은 게시물입니다.')),
                          );
                        }
                      },
                      child: const Text(
                        '...more',
                        style: TextStyle(
                          color: Colors.blue, // 하이라이트 색상
                          fontWeight: FontWeight.bold, // 강조 스타일
                        ),
                      ),
                    ),
                ],
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
