import 'package:app_team2/data/models/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pageControllerProvider = StateProvider<PageController>((ref) {
  return PageController();
});

final userProvider = StateProvider<UserModel?>((ref) => null);

final signUpFormDataProvider = StateProvider<UserModel?>((ref) {
  return UserModel(
      uid: '',
      displayName: '',
      email: '',
      photoURL:
          'https://firebasestorage.googleapis.com/v0/b/app-team2-2.firebasestorage.app/o/Default-Profile.png?alt=media&token=7da8bc98-ff57-491a-81a7-113b4a25cc62');
});

final passwordInputProvider = StateProvider<String?>((ref) {
  return null;
});
