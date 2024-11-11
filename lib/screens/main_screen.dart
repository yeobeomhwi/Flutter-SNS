import 'package:flutter/material.dart';

import '../widgets/post_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> posts = List.generate(6, (index) => 'Post #$index');
  final _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton( onPressed: () {  }, icon: const Icon(Icons.tips_and_updates),),
        title: const Text('Feed',style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [IconButton( onPressed: () {  }, icon: const Icon(Icons.notifications),),],
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          return const PostCard();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(currentIndex: _index,items:const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add Feed'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
      ]),
    );
  }
}