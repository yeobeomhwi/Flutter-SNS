import 'package:app_team2/data/models/usermodel.dart';
import 'package:app_team2/providers/signup_providers.dart';
import 'package:app_team2/services/firebase_service.dart';
import 'package:app_team2/utils/extensions/email_vaildator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import '../../widgets/login/custom_textfiled.dart';
import '../../widgets/showloading.dart';

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

              // 텍스트 필드
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
                    return '유효한 이름을 입력해 주세요. 한글, 영어만 입력 가능합니다.';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.h),

              // 회원가입 버튼
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
                    // 폼 유효성 검사
                    if (_formKey.currentState!.validate()) {
                      try {
                        // 로딩 다이얼로그 표시
                        ShowLoadingDialog.show(context);

                        // Firebase 사용자 등록
                        final user = UserModel(
                          uid: formData.state!.uid,
                          displayName: nameController.text.trim(),
                          email: formData.state!.email,
                          followers: [],
                          following: [],
                          photoURL: formData.state!.photoURL,
                        );

                        // formData 상태 업데이트
                        formData.update((state) => user);

                        // Firebase 서비스로 사용자 등록
                        String result = await FirebaseService().registerUser(
                          formData.state!.email,
                          password.state!,
                          formData.state!.displayName,
                          formData.state!.photoURL,
                        );

                        // 회원가입 성공 후
                        if (result == '회원가입이 완료되었습니다.') {
                          await FirebaseService().signOut();
                          GoRouter.of(context).go('/Login');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('회원가입이 완료되었습니다..')),
                          );
                        } else {
                          print('먼데이거 $result');
                          // 실패 메시지를 스낵바로 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),  // 여기서 result가 e.message
                          );
                        }
                      } catch (error) {
                        print(error);
                      } finally {
                        // 로딩 다이얼로그 종료
                        ShowLoadingDialog.hide(context);
                      }
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
