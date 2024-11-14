import 'package:app_team2/core/singup_constant.dart';
import 'package:app_team2/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreens extends ConsumerWidget {
  const SignUpScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = ref.watch(pageControllerProvider);
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: SignupPages,
      ),
    );
  }
}
