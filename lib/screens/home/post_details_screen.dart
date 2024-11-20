import 'package:app_team2/providers/post/post_provider.dart';
import 'package:app_team2/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailsScreen extends ConsumerWidget {
  final String postId;
  const PostDetailsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 게시물 상태 Provider 구독
    final postState = ref.watch(postProvider);

    // postId와 일치하는 post 찾기
    final post = postState.posts.firstWhere(
      (post) => post.postId == postId,
      orElse: () => throw Exception('포스트를 찾을 수 없습니다'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '포스트 상세페이지',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PostCard(
                post: post,
                hideCommentButton: true, // 댓글 버튼 숨기기 옵션 추가
              ),
              Comments(postId: postId),
            ],
          ),
        ),
      ),
    );
  }
}

class Comments extends ConsumerStatefulWidget {
  final String postId;
  const Comments({super.key, required this.postId});

  @override
  ConsumerState<Comments> createState() => _CommentsState();
}

class _CommentsState extends ConsumerState<Comments> {
  final TextEditingController _commentController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  // 키보드가 올라올 때 화면 자동 스크롤을 위한 컨트롤러
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitComment(String postId) {
    if (_commentController.text.trim().isEmpty) return;

    ref.read(postProvider.notifier).addComment(
          postId: postId,
          userId: currentUser?.uid ?? 'anonymous',
          userName: currentUser?.displayName ?? '익명',
          comment: _commentController.text.trim(),
        );
    _commentController.clear();

    // 댓글 작성 후 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 게시물 상태 Provider 구독
    final postState = ref.watch(postProvider);

    // postId와 일치하는 post 찾기
    final post = postState.posts.firstWhere(
      (post) => post.postId == widget.postId,
      orElse: () => throw Exception('포스트를 찾을 수 없습니다'),
    );
    final comments = post.comments;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildCommentsList(comments),
          ),
          _buildCommentInput(post.postId),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          'Comments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  Widget _buildCommentsList(List<dynamic> comments) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Column(
          children: [
            _CommentItem(
              comment: comment,
              currentUserId: currentUser?.uid,
              onDelete: () => ref.read(postProvider.notifier).deleteComment(
                    postId: widget.postId,
                    commentId: comment['commentId'],
                  ),
            ),
            const Divider()
          ],
        );
      },
    );
  }

  Widget _buildCommentInput(String postId) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '댓글을 작성해주세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(postId),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _submitComment(postId),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  final String? currentUserId;
  final VoidCallback onDelete;

  const _CommentItem({
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
  });

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (widget.comment['userId'] == widget.currentUserId) {
          _showDeleteDialog(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white, // 눌렀을 때 색상 변경
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row to display user name and time
            Row(
              children: [
                Text(
                  widget.comment['userName'] ??
                      'User', // If userName is null, fallback to 'User'
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.comment['createdAt'] != null
                      ? _formatCommentTime(widget.comment['createdAt'])
                      : '시간 정보 없음', // If timestamp is null, show '시간 정보 없음'
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(
                height:
                    8.0), // Add space between name+time and the comment content
            // Comment content text
            Text(
              widget.comment['comment'] ??
                  '댓글 내용 없음', // If comment is null, fallback to '댓글 내용 없음'
              style: const TextStyle(fontSize: 14),
              softWrap: true, // 자동 줄바꿈 활성화
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  String _formatCommentTime(Timestamp timestamp) {
    final commentTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(commentTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${commentTime.year}.${commentTime.month}.${commentTime.day}';
    }
  }
}
