import 'package:flutter/material.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
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
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            SocialLoginButton(
              onPressed: () {},
              buttonType: SocialLoginButtonType.google,
            ),
          ],
        ),
      ),
    );
  }
}
