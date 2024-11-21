import 'package:app_team2/providers/post/post_provider.dart';
import 'package:app_team2/widgets/custom_button.dart';
import 'package:app_team2/widgets/post_card_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_team2/core/color_constant.dart';

class UpdateCaptionScreen extends ConsumerWidget {
  final String postId;
  const UpdateCaptionScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postProvider);

    // 로딩 상태 처리
    if (postState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // postId와 일치하는 post 찾기
      final post = postState.posts.firstWhere(
        (post) => post.postId == postId,
        orElse: () {
          // 포스트를 찾지 못했을 때 로딩 시도
          ref.read(postProvider.notifier).loadPost(postId);
          throw Exception('포스트를 찾을 수 없습니다');
        },
      );

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            '게시물 수정',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
          ],
        ),
        body: UpdateCaptionForm(postId: postId, post: post),
      );
    } catch (e) {
      // 에러 발생 시 에러 화면 표시
      return Scaffold(
        appBar: AppBar(
          title: const Text('게시물 수정'),
        ),
        body: const Center(
          child: Text(
            '게시물을 불러오는 중입니다...',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
  }
}

class UpdateCaptionForm extends ConsumerStatefulWidget {
  final String postId;
  final dynamic post;

  const UpdateCaptionForm({
    super.key,
    required this.postId,
    required this.post,
  });

  @override
  ConsumerState<UpdateCaptionForm> createState() => _UpdateCaptionFormState();
}

class _UpdateCaptionFormState extends ConsumerState<UpdateCaptionForm> {
  late TextEditingController _captionController;
  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _updateCaption() async {
    if (_captionController.text.trim().isEmpty) return;

    try {
      await ref.read(postProvider.notifier).updateCaption(
            postId: widget.postId,
            newCaption: _captionController.text.trim(),
          );

      setState(() {
        isUpdated = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 수정되었습니다')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물 수정 중 오류가 발생했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            children: [
              PostCardDetils(
                post: widget.post,
                isUpdateCaption: isUpdated,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  hintText: '문구 입력...',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: greenColor),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: customButton(
                  '수정하기',
                  _updateCaption,
                  ref,
                  context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
