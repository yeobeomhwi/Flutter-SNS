import 'package:app_team2/data/database/post_database.dart';
import 'package:app_team2/providers/post_notifier.dart';
import 'package:app_team2/providers/post_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  return PostNotifier(PostDatabase.instance);
});
