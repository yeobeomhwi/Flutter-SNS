import 'package:app_team2/utils/extensions/email_vaildator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import '../../services/firebase_service.dart';
import '../../widgets/login/signup.dart';
import '../../widgets/login/custom_textfiled.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w), // 전체적인 Padding 추가
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 96.w), // 위쪽 공간
                const Center(child: Text('Logo')), // 로고 위치
                SizedBox(height: 120.h), // 로고와 입력 필드 사이의 공간
        
                // 이메일 입력 필드
                CustomTextFiled(
                  controller: emailController,
                  icon: Icons.account_circle,
                  type: 'Email',
                  focusNode: emailFocus,
                  isPassword: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '이메일을 입력해 주세요.';
                    } else if (!value.isValidEmail()) {
                      return '유효한 이메일을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.h),
        
                // 비밀번호 입력 필드
                CustomTextFiled(
                  controller: passwordController,
                  icon: Icons.lock,
                  type: 'Password',
                  focusNode: passwordFocus,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '비밀번호를 입력해 주세요.';
                    } else if (value.length < 6) {
                      return '비밀번호는 최소 6자리 이상이여야 합니다.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.h),
        
                // 로그인 버튼
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
                      if (emailController.text.isNotEmpty &&
                          passwordController.text.isNotEmpty) {
                        try {
                          await firebaseService.signInWithEmailPassword(
                            emailController.text,
                            passwordController.text,
                          );
                          await firebaseService.getFCMToken();
                          GoRouter.of(context).go('/Main');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('로그인 실패: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
        
                SizedBox(height: 10.h),
        
                // 구글 로그인 버튼
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SocialLoginButton(
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    buttonType: SocialLoginButtonType.google,
                    onPressed: () async {
                      try {
                        await firebaseService.getFCMToken();
                        await firebaseService.signInWithGoogle();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('구글 로그인 성공')),
                        );
                        GoRouter.of(context).go('/Main');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('구글 로그인 실패: $e')),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 10.h),
        
                // 회원가입 버튼
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                      SizedBox(width: 5.w),
                      TextButton(
                        onPressed: () {
                          print('분명누름');
                          GoRouter.of(context).push('/Signup');
                        },
                        child: Text(
                          "SignUp",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
