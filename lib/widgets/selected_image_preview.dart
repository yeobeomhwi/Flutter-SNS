import 'dart:io';

import 'package:flutter/material.dart';

class SelectedImagePreview extends StatelessWidget {
  final List<dynamic> pickedImages;
  
  const SelectedImagePreview({
    super.key,
    required this.pickedImages,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: pickedImages.isNotEmpty
          ? _buildSelectedImage()
          : _buildEmptyState(),
    );
  }

  Widget _buildSelectedImage() {
    return Image.file(
      File(pickedImages.last.path),
      fit: BoxFit.cover,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
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
    );
  }
}