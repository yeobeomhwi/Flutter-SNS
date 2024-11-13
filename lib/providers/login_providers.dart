import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/firebase_service.dart';
import 'firebase_providers.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final firebaseService = ref.read(firebaseServiceProvider);
  return LoginNotifier(firebaseService);
});


class LoginState {
  final bool isLoading;
  final String errorMessage;
  final bool isLoggedIn;

  LoginState({
    this.isLoading = false,
    this.errorMessage = '',
    this.isLoggedIn = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isLoggedIn,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}


class LoginNotifier extends StateNotifier<LoginState> {
  final FirebaseService firebaseService;

  LoginNotifier(this.firebaseService) : super(LoginState());

  Future<void> login(String email, String password, BuildContext context) async {
    // 유효성 검사
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: '이메일과 비밀번호를 입력해주세요.');
      return;
    }

    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(email)) {
      state = state.copyWith(errorMessage: '유효한 이메일 주소를 입력해주세요.');
      return;
    }

    if (password.length < 6) {
      state = state.copyWith(errorMessage: '비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    // 로그인 중 상태로 업데이트
    state = state.copyWith(isLoading: true);

    try {
      final user = await firebaseService.signInWithEmailPassword(email, password);
      if (user != null) {
        state = state.copyWith(isLoggedIn: true, errorMessage: '');
        GoRouter.of(context).push('/Main'); // 로그인 성공 시 메인 화면으로 이동
      } else {
        state = state.copyWith(errorMessage: '이메일과 비밀번호를 다시 확인해주세요.');
      }
    } catch (e) {
      // Firebase에서 로그인 오류가 발생한 경우
      state = state.copyWith(errorMessage: '이메일과 비밀번호를 다시 확인해주세요.');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}