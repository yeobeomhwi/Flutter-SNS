import 'package:app_team2/providers/profile/profile_notifier.dart';
import 'package:app_team2/providers/profile/profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
