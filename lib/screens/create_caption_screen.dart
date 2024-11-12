import 'package:flutter/material.dart';

class CreateCaptionScreen extends StatefulWidget {
  const CreateCaptionScreen({super.key});

  @override
  State<CreateCaptionScreen> createState() => _CreateCaptionScreenState();
}

class _CreateCaptionScreenState extends State<CreateCaptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 게시물'),),
    );
  }
}