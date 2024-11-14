import 'package:app_team2/screens/signup/signup_screen.dart';
import 'package:go_router/go_router.dart';

import '../screens/addfeed/create_caption_screen.dart';
import '../screens/addfeed/create_post_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/main_screen.dart';

class CustomRouter {
  static GoRouter router = GoRouter(
    initialLocation: "/Login",
    routes: [
      GoRoute(
        path: "/Login",
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: "/Main",
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: "/CreatePost",
        builder: (context, state) => CreatePostScreen(),
      ),
      GoRoute(
        path: "/CreateCaption",
        builder: (context, state) => CreateCaptionScreen(),
      ),
      GoRoute(
        path: "/Signup",
        builder: (context, state) => SignUpScreens(),
      ),
    ],
    // redirect: (context, state) {
    //   final User? user = FirebaseAuth.instance.currentUser;
    //
    //   // 로그인하지 않은 경우 로그인 화면으로 리디렉션
    //   if (user == null) {
    //     if (state.uri.toString() != '/Login') {
    //       return '/Login'; // 로그인 화면으로 리디렉션
    //     }
    //   }
    //
    //   // 로그인한 경우 Main 화면으로 리디렉션
    //   if (user != null && state.uri.toString() == '/Login') {
    //     return '/Main'; // 메인 화면으로 리디렉션
    //   }
    //
    //   return null; // 기본적으로 경로 유지
    // },
  );
}
