import 'package:app_team2/data/repositories/post_repository.dart';
import 'package:app_team2/providers/post/post_notifier.dart';
import 'package:app_team2/providers/post/post_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  final postRepository = PostRepository();
  return PostNotifier(postRepository);
});
