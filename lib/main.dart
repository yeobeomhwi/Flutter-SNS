import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeLocalNotifications();
  await requestNotificationPermission();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: CustomRouter.router,
        title: 'Anytime Post',
        theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white, foregroundColor: Colors.black),
            primaryColor: Colors.white,
            textTheme: Typography.material2021().black.apply(
                  fontFamily: 'Pretendard',
                ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
            )),
        // 기본 라이트모드 테마
        darkTheme: ThemeData.dark().copyWith(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey),
            textTheme: Typography.material2021().white.apply(
                  fontFamily: 'Pretendard',
                )),
        // 기본 다크모드 테마
        themeMode: ThemeMode.system, // 시스템 설정에 따라 자동 전환
      ),
    );
  }
}
