import 'package:app_team2/data/models/usermodel.dart';
import 'package:app_team2/providers/signup/signup_providers.dart';
import 'package:app_team2/utils/extensions/email_vaildator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import '../../widgets/login/custom_textfiled.dart';

class EmailInputScreen extends ConsumerStatefulWidget {
  const EmailInputScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EmailInputScreenState();
}

class _EmailInputScreenState extends ConsumerState<EmailInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    emailFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(pageControllerProvider);
    final formData = ref.watch(signUpFormDataProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/Login'),
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
                '사용자 이메일 입력',
                style: TextStyle(
                  fontSize: 26.sp,
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
                controller: emailController,
                icon: Icons.account_circle,
                type: 'Email',
                focusNode: emailFocusNode,
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

              SizedBox(height: 20.h),

              //다음 버튼
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: SocialLoginButton(
                  backgroundColor: Colors.black,
                  height: 50.h,
                  text: '다음',
                  textColor: Colors.white,
                  fontSize: 16.sp,
                  buttonType: SocialLoginButtonType.generalLogin,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      formData.update((state) => UserModel(
                            uid: formData.state!.uid,
                            displayName: formData.state!.displayName,
                            email: emailController.text.trim(),
                            photoURL: formData.state!.photoURL,
                          ));

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
