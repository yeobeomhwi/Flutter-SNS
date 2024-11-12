import 'package:app_team2/screens/main_screen.dart';
import '../screens/addfeed/create_caption_screen.dart';
import '../screens/addfeed/create_post_screen.dart';
import '../screens/login/login_screen.dart';
import 'package:go_router/go_router.dart';

import '../screens/signup/signup_screen.dart';

class CustomRouter {
  static GoRouter router = GoRouter(initialLocation: "/Login", routes: [
    GoRoute(path: "/Login", builder: (context, state) => LoginScreen()),
    GoRoute(path: "/Signup", builder: (context, state) => const SignupScreen()),
    GoRoute(path: "/Main", builder: (context, state) => const MainScreen()),
    GoRoute(path: "/CreatePost", builder: (context, state) =>  CreatePostScreen()),
    GoRoute(path: "/CreateCaption", builder: (context, state) => CreateCaptionScreen())
  ]);
}
