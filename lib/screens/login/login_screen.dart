import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import '../../services/firebase_service.dart';
import '../../widgets/login/signup.dart';
import '../../widgets/login/textfiled.dart';
import '../../widgets/login/forgot.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen> {
  final firebaseService = FirebaseService(); // FirebaseService 인스턴스 생성
  final emailController = TextEditingController();
  FocusNode email_F = FocusNode();
  final passwordController = TextEditingController();
  FocusNode password_F = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 96.w, height: 100.w),
            Center(child: Text('Logo')),
            SizedBox(height: 120.h),
            TextFiled(
              controller: emailController,
              icon: Icons.email,
              type: 'Email',
              focusNode: email_F,
              isPassword: false,
            ),
            SizedBox(height: 15.h),
            TextFiled(
              controller: passwordController,
              icon: Icons.lock,
              type: 'Password',
              focusNode: password_F,
              isPassword: false,
            ),
            SizedBox(height: 10.h),
            Forgot(),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: SocialLoginButton(
                backgroundColor: Colors.black,
                height: 50,
                text: 'Login',
                textColor: Colors.white,
                fontSize: 16,
                buttonType: SocialLoginButtonType.generalLogin,
                onPressed: () async {
                  await firebaseService.signInWithEmailPassword(
                    emailController.text,
                    passwordController.text,
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: SocialLoginButton(
                backgroundColor: Colors.black,
                textColor: Colors.white,
                buttonType: SocialLoginButtonType.google,
                onPressed: () async {
                  try {
                    await firebaseService.signInWithGoogle(); // 구글 로그인 호출
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('구글 로그인 성공')),
                    );
                    GoRouter.of(context).go('/Main'); // 로그인 후 홈 화면으로 이동
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('구글 로그인 실패: $e')),
                    );
                    print(e);
                  }
                },
              ),
            ),
            SizedBox(height: 10.h),
            SignUp()
          ],
        ),
      ),
    );
  }
}
