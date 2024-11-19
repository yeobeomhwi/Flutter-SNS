import 'package:app_team2/data/database/post_database.dart';
import 'package:app_team2/data/models/post.dart';

class PostRepository {
  final PostDatabase _database = PostDatabase.instance;

  Future<void> savePost(Post post) async {
    await _database.createPost(post);
  }

  Future<List<Post>> getAllPosts() async {
    return await _database.readAllPosts();
  }

  Future<Post?> getPostById(String id) async {
    return await _database.readPost(id);
  }

  Future<void> updatePost(Post post) async {
    await _database.updatePost(post);
  }

  Future<void> deletePost(String id) async {
    await _database.deletePost(id);
  }
}
