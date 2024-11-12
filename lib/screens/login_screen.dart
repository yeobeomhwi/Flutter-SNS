import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

class LoginScreen extends ConsumerWidget {
  final emailProvider = StateProvider<String>((ref) => '');
  final passwordProvider = StateProvider<String>((ref) => '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                ref.read(emailProvider.notifier).state = value;
              },
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              onChanged: (value) {
                ref.read(passwordProvider.notifier).state = value;
              },
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 40),
            SocialLoginButton(
              backgroundColor: Colors.white,
              height: 50,
              text: 'Login with Email',
              textColor: Colors.black,
              fontSize: 20,
              buttonType: SocialLoginButtonType.generalLogin,
              onPressed: () {
                print('Email: $email');
                print('Password: $password');
                GoRouter.of(context).push('/Main');
              },
            ),
            const SizedBox(height: 20),
            SocialLoginButton(
              onPressed: () {},
              buttonType: SocialLoginButtonType.google,
            ),
            SizedBox(height: 20),
            Divider(),
            SocialLoginButton(
              backgroundColor: Colors.white,
              height: 50,
              text: 'Sign Up with Email',
              textColor: Colors.black,
              fontSize: 20,
              buttonType: SocialLoginButtonType.generalLogin,
              onPressed: () {
                GoRouter.of(context).push('/Signup');
              },
            ),
          ],
        ),
      ),
    );
  }
}
