import 'package:app_team2/widgets/comment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app_team2/data/models/post.dart';

import '../services/firebase_service.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  final PageController _controller = PageController();
  List<String> likes = [];

  @override
  void initState() {
    super.initState();
    likes = List<String>.from(widget.post.likes); // 초기 likes 설정
    print(likes);
  }

  // Firestore에서 포스트의 좋아요 상태를 토글하는 함수
  Future<void> toggleLike(String postId) async {
    // Call the toggleLikePost method from FirebaseService
    await FirebaseService().toggleLikePost(postId);

    // Optionally, you can update the local state to reflect the changes (if needed)
    setState(() {
      likes = List<String>.from(widget.post.likes);
    });
  }

  var uid = FirebaseService().getCurrentUserUid();

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
                backgroundImage: NetworkImage(widget.post.profileImage),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(widget.post.userName),
              const Spacer(),
              IconButton(
                onPressed: () {},
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
              return Image.network(
                widget.post.imageUrls[index],
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              );
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
                  // Firestore에서 좋아요 상태를 토글
                  toggleLike(widget.post.postId);
                },
                icon: Icon(
                  Icons.favorite,
                  color: likes.contains(uid) ? Colors.red : null,
                ),
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => CommentDialog(
                      postId: widget.post.postId,
                      comments: widget.post.comments ?? [],
                      onAddComment: (String comment) async {
                        await FirebaseService()
                            .addComment(widget.post.postId, comment);
                        if (mounted) {
                          setState(() {
                            // 댓글이 추가된 후 상태 업데이트
                          });
                        }
                      },
                      onDeleteComment: (String commentId) async {
                        await FirebaseService()
                            .deleteComment(widget.post.postId, commentId);
                        if (mounted) {
                          setState(() {
                            // 댓글이 삭제된 후 상태 업데이트
                          });
                        }
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.comment_outlined),
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
