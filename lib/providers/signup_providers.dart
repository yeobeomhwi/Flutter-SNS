import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 현재 Step 상태와 로직을 관리하는 Notifier
class SignupStepController extends StateNotifier<int> {
  SignupStepController() : super(0);

  void onStepCancel() {
    if (state > 0) state--;
  }

  void onStepContinue() {
    if (state < 2) state++;
  }
}

// Provider로 SignupStepController를 제공
final signupStepProvider = StateNotifierProvider<SignupStepController, int>(
      (ref) => SignupStepController(),
);

// 비밀번호 표시 여부 상태
final obscurePasswordProvider = StateProvider<bool>((ref) => true);

// 각 입력 필드의 TextEditingController를 관리하는 StateProvider
final emailControllerProvider = Provider((ref) => TextEditingController());
final passwordControllerProvider = Provider((ref) => TextEditingController());
final nameControllerProvider = Provider((ref) => TextEditingController());
