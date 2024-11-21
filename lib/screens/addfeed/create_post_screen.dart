import 'dart:io';
import 'package:app_team2/layout/default_layout.dart';
import 'package:app_team2/providers/post/picked_images_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app_team2/widgets/selected_image_preview.dart';
import 'package:app_team2/widgets/custom_button.dart';

class CreatePostScreen extends ConsumerWidget {
  CreatePostScreen({super.key});

  final ImagePicker _picker = ImagePicker();

  // 이미지 선택 함수
  void getImage(ImageSource source, WidgetRef ref) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      ref.read(pickedImagesProvider.notifier).addImage(image);
    }
  }

  // 이미지 복수 선택 함수
  void getMultiImage(WidgetRef ref) async {
    final List<XFile> images = await _picker.pickMultiImage();
    ref.read(pickedImagesProvider.notifier).addImages(images);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickedImages = ref.watch(pickedImagesProvider);

    return DefaultLayout(
      title: '새 게시글 작성',
      actions: [
        TextButton(
          onPressed: () {
            if (pickedImages.isNotEmpty) {
              context.push('/CreateCaption');
            } else {
              // 이미지가 선택되지 않았을 때 경고 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이미지를 선택해주세요.')),
              );
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
          child: Text(
            '다음',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              // 최근에 선택된 이미지 표시
              const SelectedImagePreview(),
              const SizedBox(height: 20),
              // 이미지 불러오기 버튼
              _imageLoadButtons(ref, context),
              const SizedBox(height: 20),
              // 선택된 이미지 gridView
              _gridPhoto(pickedImages, ref),
            ],
          ),
        ),
      ),
    );
  }

  // 이미지 불러오기 버튼
  Widget _imageLoadButtons(WidgetRef ref, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customButton(
              '카메라', () => getImage(ImageSource.camera, ref), ref, context),
          const SizedBox(width: 20),
          customButton('갤러리', () => getMultiImage(ref), ref, context),
        ],
      ),
    );
  }

  // 선택된 이미지 gridView
  Widget _gridPhoto(List<XFile> pickedImages, WidgetRef ref) {
    return Expanded(
      child: pickedImages.isNotEmpty
          ? GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              children:
                  pickedImages.map((e) => _gridPhotoItem(e, ref)).toList(),
            )
          : const Center(
              child: Text(
                '선택된 사진이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
    );
  }

  Widget _gridPhotoItem(XFile e, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(e.path),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                ref.read(pickedImagesProvider.notifier).removeImage(e);
              },
              child: const Icon(
                Icons.cancel_rounded,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }
}
