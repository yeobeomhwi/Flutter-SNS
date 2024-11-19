
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/post/post_provider.dart';

class CommentDialog extends ConsumerStatefulWidget {
  final String postId;

  const CommentDialog({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends ConsumerState<CommentDialog> {
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
    final postState = ref.watch(postProvider);
    final post = postState.posts.firstWhere(
      (post) => post.postId == widget.postId,
      orElse: () => throw Exception('Post not found'),
    );
    final comments = post.comments;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
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
      padding: const EdgeInsets.only(bottom: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<dynamic> comments) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return _CommentItem(
          comment: comment,
          currentUserId: currentUser?.uid,
          onDelete: () => ref.read(postProvider.notifier).deleteComment(
                postId: widget.postId,
                commentId: comment['commentId'],
              ),
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

class _CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final String? currentUserId;
  final VoidCallback onDelete;

  const _CommentItem({
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildAvatar(),
      title: Text(
        comment['userName'] ?? '익명',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(comment['comment']),
          ),
          Text(
            comment['timestamp'] != null
                ? _formatCommentTime(comment['timestamp'])
                : '',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      trailing: comment['userId'] == currentUserId
          ? IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
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
                          onDelete();
                          Navigator.pop(context);
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildAvatar() {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      child: currentUser?.photoURL?.isNotEmpty == true
          ? ClipOval(
              child: Image.network(
                currentUser!.photoURL!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, color: Colors.grey);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            )
          : const Icon(Icons.person, color: Colors.grey),
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