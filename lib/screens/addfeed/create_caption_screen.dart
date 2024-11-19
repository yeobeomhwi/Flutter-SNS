import 'dart:io';
import 'package:app_team2/providers/post/picked_images_provider.dart';
import 'package:app_team2/providers/post/post_provider.dart';
import 'package:app_team2/providers/profile/profile_proivder.dart';
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
  bool _isLoading = false;

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
                            // Firebase에서 현재 로그인한 사용자의 uid 가져오기
                            final firebaseUser =
                                FirebaseService().getCurrentUser();
                            if (firebaseUser == null) {
                              throw Exception('로그인된 사용자가 없습니다');
                            }

                            // 먼저 온라인으로 데이터를 가져오기 시도
                            await ref
                                .read(profileProvider.notifier)
                                .loadUserDataOnline(firebaseUser.uid);

                            // 온라인 로드가 실패하면 오프라인 데이터 시도
                            final userState = ref.read(profileProvider);
                            if (userState.error != null) {
                              await ref
                                  .read(profileProvider.notifier)
                                  .loadUserDataOffline(firebaseUser.uid);
                            }

                            // 최종 상태 확인
                            final finalState = ref.read(profileProvider);
                            final currentUser = finalState.user;

                            if (currentUser == null) {
                              throw Exception('사용자 정보를 불러올 수 없습니다.');
                            }

                            // PostNotifier를 사용해 포스트 추가
                            await ref.read(postProvider.notifier).addPost(
                                  userId: currentUser.uid,
                                  userName: currentUser.displayName,
                                  profileImage: currentUser.photoURL,
                                  imagePaths: imagePaths,
                                  caption: _captionController.text,
                                );

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
