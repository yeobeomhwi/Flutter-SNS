import 'dart:io';
import 'package:app_team2/data/repositories/post_repository.dart';
import 'package:app_team2/providers/picked_images_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/post.dart';
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
    final List<String> imagePaths =
        pickedImages.map((xFile) => xFile.path).toList();

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

                          try {
                            // UUID 생성하여 고유 ID 생성
                            final String postId = const Uuid().v4();

                            // SharedPreferences에서 현재 로그인한 사용자 정보를 가져오는 로직 필요
                            const String userId =
                                'local_user_id'; // shared_preferences로 사용자 정보 관리 구현 후 대체
                            const String userName =
                                'local_user_name'; // shared_preferences로 사용자 정보 관리 구현 후 대체
                            const String profileImage =
                                'default_profile_image_path'; // shared_preferences로 사용자 정보 관리 구현 후 대체

                            // Post 객체 생성
                            final post = Post(
                              postId: postId,
                              userId: userId,
                              userName: userName,
                              profileImage: profileImage,
                              imagePaths: imagePaths, // 선택된 이미지들의 로컬 경로
                              caption: _captionController.text,
                              createdAt: DateTime.now(),
                              likes: [],
                              comments: [],
                            );

                            // PostRepository 인스턴스 생성
                            final postRepository = PostRepository();

                            // 포스트 저장
                            await postRepository.savePost(post);

                            // 성공 메시지 표시
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('포스트가 성공적으로 저장되었습니다.'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }

                            // 이미지 초기화
                            ref
                                .read(pickedImagesProvider.notifier)
                                .clearImages();

                            // 텍스트 필드 비우기
                            _captionController.clear();

                            // 메인 화면으로 이동
                            if (mounted) {
                              context.go('/Main');
                            }
                          } catch (e) {
                            // 에러 처리
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '포스트 저장 중 오류가 발생했습니다: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            // 로딩 상태 해제
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
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
