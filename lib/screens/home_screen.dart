import 'package:flutter/material.dart';

import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> posts = List.generate(6, (index) => 'Post #$index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tips_and_updates),
        ),
        title: const Text(
          'Feed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext context, int index) {
            return const PostCard();
          },
        ),
      ),
    );
  }
}
