import 'package:app_team2/screens/addfeed/update_caption_screen.dart';
import 'package:app_team2/screens/home/post_details_screen.dart';
import 'package:app_team2/screens/notifications/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../screens/addfeed/create_caption_screen.dart';
import '../screens/addfeed/create_post_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/signup/signup_screen.dart';

class CustomRouter {
  static GoRouter router = GoRouter(
    initialLocation: "/Login",
    routes: [
      GoRoute(
        path: "/Login",
        builder: (context, state) => const LoginScreen(),
      ),
      // MainScreen을 ConsumerWidget으로 감싸기 위해 ProviderScope로 감싸는 방법
      GoRoute(
        path: "/Main",
        builder: (context, state) => const MainScreenWrapper(),
      ),
      GoRoute(
        path: "/CreatePost",
        builder: (context, state) => CreatePostScreen(),
      ),
      GoRoute(
        path: "/CreateCaption",
        builder: (context, state) => const CreateCaptionScreen(),
      ),
      GoRoute(
        path: '/Signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/Notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/PostDetails',
        builder: (context, state) => PostDetailsScreen(
          postId: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/UpdateCaption',
        builder: (context, state) => UpdateCaptionScreen(
          postId: state.extra as String,
        ),
      ),
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // 로그인 화면 또는 회원가입 화면으로 접근할 수 있도록 수정
        if (state.uri.toString() != '/Login' && state.uri.toString() != '/Signup') {
          return '/Login';
        }
      }

      if (user != null && state.uri.toString() == '/Login') {
        return '/Main'; // 메인 화면으로 리디렉션
      }

      return null; // 기본적으로 경로 유지
    },
  );
}