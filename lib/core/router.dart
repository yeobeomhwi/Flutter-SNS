import 'package:app_team2/screens/main_screen.dart';

import '../screens/login_screen.dart';
import 'package:go_router/go_router.dart';

import '../screens/signup_screen.dart';

class CustomRouter {
  static GoRouter router = GoRouter(initialLocation: "/Login", routes: [
    GoRoute(path: "/Login", builder: (context, state) => LoginScreen()),
    GoRoute(path: "/Signup", builder: (context, state) => const SignupScreen()),
    GoRoute(path: "/Main", builder: (context, state) => const MainScreen())
  ]);
}
