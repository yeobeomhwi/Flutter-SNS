import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pickedImages = [];
  
  // 카메라, 갤러리에서 이미지 1개 불러오기
  // ImageSource.galley , ImageSource.camera 
  void getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) { // 선택된 이미지가 null이 아닐 때만 추가
      setState(() {
        _pickedImages.add(image); // 안전하게 추가
      });
    }
  }
  
  // 이미지 여러개 불러오기
  void getMultiImage() async {
    final List<XFile> images = await _picker.pickMultiImage();

 // 선택된 이미지가 null이 아닐 때만 추가
    setState(() {
      _pickedImages.addAll(images);
    });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a Post'), actions: [TextButton(onPressed: () {}, child: const Text('다음'),),],),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              // 상단에 선택된 이미지 표시
  _pickedImages.isNotEmpty
      ? SizedBox(
          height: 400, // 이미지 표시할 높이
          width: double.infinity,
          child: Image.file(
            File(_pickedImages.last.path), // 가장 최근에 선택된 이미지
            fit: BoxFit.cover,
          ),
        )
      : const SizedBox(
          height: 400, // 아이콘을 표시할 높이
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo,
                  size: 100, // 아이콘 크기
                  color: Colors.grey, // 아이콘 색상
                ),
                SizedBox(height: 10),
                Text(
                  '사진이 선택되지 않았습니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
              const SizedBox(height: 20),
              _imageLoadButtons(),
              const SizedBox(height: 20),
              _gridPhoto(),
            ],
          ),
        ),
      ),
    );
  }
  
  // 화면 상단 버튼
  Widget _imageLoadButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: ElevatedButton(
              onPressed: () => getImage(ImageSource.camera),
              child: const Text('Camera'),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            child: ElevatedButton(
              onPressed: () => getImage(ImageSource.gallery),
              child: const Text('Image'),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            child: ElevatedButton(
              onPressed: () => getMultiImage(),
              child: const Text('Multi Image'),
            ),
          ),
        ],
      ),
    );
  }
  
  // 불러온 이미지 gridView
  Widget _gridPhoto() {
    return Expanded(
      child: _pickedImages.isNotEmpty
          ? GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              children: _pickedImages
                  .where((element) => element != null)
                  .map((e) => _gridPhotoItem(e))
                  .toList(),
            )
          : const SizedBox(),
    );
  }

  Widget _gridPhotoItem(XFile e) {
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
                setState(() {
                  _pickedImages.remove(e);
                });
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