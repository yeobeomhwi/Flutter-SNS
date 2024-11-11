import 'package:flutter/material.dart';

import '../widgets/post_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> posts = List.generate(6, (index) => 'Post #$index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton( onPressed: () {  }, icon: const Icon(Icons.tips_and_updates),),
        title: Text('Feed'),
        actions: [IconButton( onPressed: () {  }, icon: const Icon(Icons.notifications),),],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          return PostCard();
        },
      ),
    );
  }
}