import 'package:app_team2/screens/home/home_screen.dart';
import 'package:app_team2/screens/profile/profile_screen.dart';
import 'package:app_team2/screens/addfeed/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bottom_nav/bottom_nav_provider.dart'; // 프로바이더 파일 경로

// MainScreen을 ConsumerWidget으로 정의
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Widget> screens = [
      HomeScreen(),
      CreatePostScreen(),
      ProfileScreen(),
    ];

    // 상태를 읽어옵니다.
    final currentIndex = ref.watch(bottomNavIndexProvider).index;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,  // currentIndex는 int 값이어야 합니다.
        children: screens,    // 여기서 _screens가 아닌 screens를 사용합니다.
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,  // currentIndex는 int 값이어야 합니다.
        onTap: (int index) {
          ref.read(bottomNavIndexProvider.notifier).setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}

// MainScreen을 ConsumerWidget으로 감싸는 Wrapper
class MainScreenWrapper extends StatelessWidget {
  const MainScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child:  MainScreen(),
    );
  }
}

