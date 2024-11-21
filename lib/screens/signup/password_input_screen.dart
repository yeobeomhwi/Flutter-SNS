import 'package:app_team2/providers/signup/signup_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import '../../widgets/login/custom_textfiled.dart';

class PasswordInputScreen extends ConsumerStatefulWidget {
  const PasswordInputScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PasswordInputScreenState();
}

class _PasswordInputScreenState extends ConsumerState<PasswordInputScreen> {
  final passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(pageControllerProvider);
    final password = ref.watch(passwordInputProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            pageController.previousPage(
              duration: const Duration(microseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),

              Text(
                '사용자 비밀번호 입력',
                style: TextStyle(
                  fontSize: 26.sp, // flutter_screenutil 적용
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                '등록 후 변경할 수 없습니다.',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),

              SizedBox(height: 15.h),

              //텍스트 필드
              CustomTextFiled(
                controller: passwordController,
                icon: Icons.lock,
                type: 'Password',
                focusNode: passwordFocusNode,
                isPassword: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return '비밀번호를 입력해 주세요.';
                  } else if (value.length < 6) {
                    return '비밀번호는 최소 6자리 이상이어야 합니다.';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.h),

              //다음 버튼
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: SocialLoginButton(
                  borderRadius: 30,
                  backgroundColor: Colors.black,
                  height: 50.h, // flutter_screenutil 적용
                  text: '다음',
                  textColor: Colors.white,
                  fontSize: 16.sp, // flutter_screenutil 적용
                  buttonType: SocialLoginButtonType.generalLogin,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      password.state = passwordController.text.trim();
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
