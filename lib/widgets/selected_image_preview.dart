import 'dart:io';
import 'package:app_team2/providers/picked_images_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SelectedImagePreview extends ConsumerWidget {
  const SelectedImagePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickedImages = ref.watch(pickedImagesProvider);
    
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: pickedImages.isNotEmpty
          ? Image.file(
              File(pickedImages.last.path),
              fit: BoxFit.cover,
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '사진을 선택해 주세요.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}