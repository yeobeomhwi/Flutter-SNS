import 'dart:io';

import 'package:app_team2/model/post.dart';
import 'package:app_team2/model/user.dart';
import 'package:app_team2/providers/picked_images_provider.dart';
import 'package:app_team2/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateCaptionScreen extends ConsumerStatefulWidget {
  const CreateCaptionScreen({super.key});

  @override
  ConsumerState<CreateCaptionScreen> createState() =>
      _CreateCaptionScreenState();
}

class _CreateCaptionScreenState extends ConsumerState<CreateCaptionScreen> {
  final TextEditingController _captionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _captionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickedImages = ref.watch(pickedImagesProvider);
    final reversedImages = pickedImages.reversed.toList();
    // final caption = _captionController.text;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('새 게시물'),
        ),
        // resizeToAvoidBottomInset: false,
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
                if (reversedImages.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: PageView.builder(
                      padEnds: false,
                      controller: PageController(
                        viewportFraction: 0.22,
                      ),
                      itemCount: reversedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(reversedImages[index].path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(pickedImagesProvider.notifier)
                                        .removeImage(reversedImages[index]);
                                  },
                                  child: const Icon(
                                    Icons.cancel_rounded,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                  onPressed: () async {
                    // FirebaseService 인스턴스 생성
                    final FirebaseService firebaseService = FirebaseService();
                    // Post 생성 및 저장
                    try {
                      await Post.createPost(
                        ref, // WidgetRef 인스턴스
                        _captionController,
                        firebaseService,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('포스트가 성공적으로 작성되었습니다.'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // 초기화 및 화면 이동
                      await Future.delayed(
                          const Duration(milliseconds: 500)); // 0.5초 딜레이
                      // 이미지 및 텍스트 초기화
                      ref.read(pickedImagesProvider.notifier).clearImages();
                      _captionController.clear();
                      // 메인 화면으로 이동
                      context.go('/Main');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('오류가 발생했습니다.: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
