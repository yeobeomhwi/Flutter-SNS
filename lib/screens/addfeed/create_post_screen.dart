import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app_team2/providers/picked_images_provider.dart';
import 'package:app_team2/widgets/selected_image_preview.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Post'),
        actions: [
          TextButton(
            onPressed: () {
              context.push('/CreateCaption');
            },
            child: const Text('다음'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              // 최근에 선택된 이미지 표시
              const SelectedImagePreview(),
              const SizedBox(height: 20),
              // 이미지 불러오기 버튼
              _imageLoadButtons(ref),
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
  Widget _imageLoadButtons(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: ElevatedButton(
              onPressed: () => getImage(ImageSource.camera, ref),
              child: const Text('Camera'),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            child: ElevatedButton(
              onPressed: () => getImage(ImageSource.gallery, ref),
              child: const Text('Image'),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            child: ElevatedButton(
              onPressed: () => getMultiImage(ref),
              child: const Text('Multi Image'),
            ),
          ),
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
          : const SizedBox(),
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
