import 'package:app_team2/screens/home/home_screen.dart';
import 'package:app_team2/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'addfeed/create_post_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    CreatePostScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box), label: 'Add Feed'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Profile'),
          ]),
    );
  }
}
