import 'dart:io';
import 'package:app_team2/providers/post/picked_images_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/post.dart';
import '../../providers/post/post_provider.dart';
import '../../services/firebase_service.dart';

class CreateCaptionScreen extends ConsumerStatefulWidget {
  const CreateCaptionScreen({super.key});

  @override
  ConsumerState<CreateCaptionScreen> createState() =>
      _CreateCaptionScreenState();
}

class _CreateCaptionScreenState extends ConsumerState<CreateCaptionScreen> {
  final TextEditingController _captionController = TextEditingController();
  final FirebaseService firebaseService = FirebaseService();
  bool _isLoading = false; // 로딩 상태 변수 추가

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickedImages = ref.watch(pickedImagesProvider);
    final List<File> imagePaths =
        pickedImages.map((xFile) => File(xFile.path)).toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('새 게시물'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: pickedImages.isEmpty
                      ? const Center(
                          child: Text('선택된 이미지가 없습니다'),
                        )
                      : Image.file(
                          File(pickedImages.last.path),
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _captionController,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // 로딩 중일 때 버튼 비활성화
                          setState(() {
                            _isLoading = true; // 로딩 시작
                          });

                          final userId = firebaseService.getCurrentUserUid();
                          try {
                            final postId = '${userId}_'
                                '${DateTime.now().millisecondsSinceEpoch}';

                            // 프로필 이미지 가져오기
                            final profileImage =
                                firebaseService.getCurrentUser()!.photoURL ??
                                    '';

                            // 로컬에 게시물 추가
                            ref.read(postNotifierProvider.notifier).addPost(
                              postId: postId,
                              userId: userId!,
                              userName: firebaseService
                                  .getCurrentUser()!
                                  .displayName
                                  .toString(),
                              caption: _captionController.text,
                              imageUrls: imagePaths.map((e) => e.path).toList(),
                              isSynced: false,
                              profileImage: profileImage,
                              createdAt: FieldValue.serverTimestamp(),
                              likes: [],
                              comments: [],
                            );

                            // 성공 메시지 표시
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('포스트가 성공적으로 작성되었습니다.'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            // 이미지 초기화 및 텍스트 필드 비우기
                            ref
                                .read(pickedImagesProvider.notifier)
                                .clearImages();
                            _captionController.clear();

                            // 메인 화면으로 이동
                            context.go('/Main');
                          } catch (e) {
                            // 더 구체적인 에러 메시지 처리 가능
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('오류가 발생했습니다: ${e.toString()}')),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false; // 로딩 종료
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Post'),
                ),
                if (_isLoading) // 로딩 중이면 인디케이터 표시
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
