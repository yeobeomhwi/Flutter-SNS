import 'package:flutter/material.dart';

class PhotourlInputScreen extends StatefulWidget {
  const PhotourlInputScreen({super.key});

  @override
  State<PhotourlInputScreen> createState() => _PhotourlInputScreenState();
}

class _PhotourlInputScreenState extends State<PhotourlInputScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('PhotoUrl'),
      ),
    );
  }
}
