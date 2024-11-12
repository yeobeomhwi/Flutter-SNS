import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';
import 'firebase_providers.dart';

final emailControllerProvider = StateProvider<String>((ref) => '');
final passwordControllerProvider = StateProvider<String>((ref) => '');

// FirebaseService 인스턴스 Provider
final firebaseServiceProvider = Provider((ref) => FirebaseService());


final performLoginProvider = FutureProvider.family<void, BuildContext>((ref, context) async {
  final firebaseService = ref.read(firebaseServiceProvider);
  final email = ref.read(emailControllerProvider);
  final password = ref.read(passwordControllerProvider);

  try {
    final user = await firebaseService.signInWithEmailPassword(email, password);
    if (user != null) {
      ref.refresh(currentUserProvider); // 로그인 후 사용자 정보 리프레시
      GoRouter.of(context).push('/Main'); // 로그인 성공 시 메인 화면으로 이동
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login error: ${e.toString()}')),
    );
  }
});
