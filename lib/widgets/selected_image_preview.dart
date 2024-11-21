import 'dart:io';
import 'package:app_team2/providers/post/picked_images_provider.dart';
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
          : Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo,
                      size: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
