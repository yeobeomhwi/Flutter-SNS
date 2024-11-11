import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DefaultLayout({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}