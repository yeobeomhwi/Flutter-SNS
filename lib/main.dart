
import 'package:app_team2/screens/login_screen.dart';
import 'package:app_team2/screens/main_screen.dart';
import 'package:app_team2/screens/signup_screen.dart';
import 'package:app_team2/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(  // Wrap your app with ProviderScope
      child: MaterialApp.router(
        routerConfig: CustomRouter.router,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ), // Your LoginScreen widget
      ),
    );
  }
}
