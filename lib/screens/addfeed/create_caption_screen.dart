import 'dart:io';
import 'package:app_team2/providers/post/picked_images_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                            // 포스트 생성
                            await firebaseService.createPost(
                              userId!,
                              _captionController.text,
                              imagePaths,
                            );

                            // 성공 메시지 표시
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('포스트가 성공적으로 작성되었습니다.'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            // 초기화 및 화면 이동
                            ref
                                .read(pickedImagesProvider.notifier)
                                .clearImages(); // 이미지 초기화
                            _captionController.clear(); // 텍스트 필드 비우기

                            // 메인 화면으로 이동
                            context.go('/Main');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('오류가 발생했습니다.: $e')),
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
