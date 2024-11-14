import 'package:app_team2/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

import '../../widgets/login/TextFiled.dart';

class NameInputScreen extends ConsumerWidget {
  final nameController = TextEditingController();
  FocusNode name_F = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = ref.watch(pageControllerProvider);

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Text(
            '사용자 이름 입력',
            style: TextStyle(
                fontSize: 26.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          Text(
            '등록 후 언제든지 변경할 수 있습니다.',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          SizedBox(height: 15.h),
          TextFiled(
              controller: nameController,
              icon: Icons.email,
              type: 'Name',
              focusNode: name_F,
              isPassword : false
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: SocialLoginButton(
              backgroundColor: Colors.black,
              height: 50,
              text: '다음',
              textColor: Colors.white,
              fontSize: 16,
              buttonType: SocialLoginButtonType.generalLogin,
              onPressed: () {
                pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
            ),
          ),
        ],
      ),
    );
  }
}
