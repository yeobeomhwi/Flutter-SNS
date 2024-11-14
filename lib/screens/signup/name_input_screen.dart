import 'package:app_team2/data/models/usermodel.dart';
import 'package:app_team2/providers/signup_providers.dart';
import 'package:app_team2/services/firebase_service.dart';
import 'package:app_team2/utils/extensions/email_vaildator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import '../../widgets/login/custom_textfiled.dart';

class NameInputScreen extends ConsumerStatefulWidget {
  const NameInputScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends ConsumerState<NameInputScreen> {
  final nameController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(pageControllerProvider);
    final formData = ref.watch(signUpFormDataProvider.notifier);
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
          padding: EdgeInsets.symmetric(horizontal: 20.w),  // padding 적용
          child: Column(
            children: [

              SizedBox(height: 10.h),

              Text(
                '사용자 이름 입력',
                style: TextStyle(
                  fontSize: 26.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                '등록 후 언제든지 변경할 수 있습니다.',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),

              SizedBox(height: 15.h),

              //텍스트 필드
              CustomTextFiled(
                controller: nameController,
                icon: Icons.account_circle,
                type: 'Name',
                focusNode: nameFocusNode,
                isPassword: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return '이름을 입력해 주세요.';
                  } else if (value.length < 3) {
                    return '이름은 최소 3글자 이상이어야 합니다.';
                  } else if (!value.isValidName()) {
                    return '유효한 이름을 입력해 주세요.';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.h),

              //회원가입 버튼
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: SocialLoginButton(
                  backgroundColor: Colors.black,
                  height: 50.h,
                  text: '회원가입',
                  textColor: Colors.white,
                  fontSize: 16.sp,
                  buttonType: SocialLoginButtonType.generalLogin,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final user = UserModel(
                        uid: formData.state!.uid,
                        displayName: nameController.text.trim(),
                        email: formData.state!.email,
                        followers: [],
                        following: [],
                        photoURL: formData.state!.photoURL,
                      );
                      formData.update((state) => user);

                      await FirebaseService().registerUser(
                        formData.state!.email,
                        password.state!,
                        formData.state!.displayName,
                        formData.state!.photoURL,
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
