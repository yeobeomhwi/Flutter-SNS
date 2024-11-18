import 'dart:io';

import 'package:app_team2/data/models/post.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class PostDatabase {
  static final PostDatabase instance = PostDatabase._init();
  static Database? _database;

  PostDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('posts.db');
    return _database!;
  }

  // 데이터베이스 초기화
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // 테이블 생성
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts(
        postId TEXT PRIMARY KEY,
        userId TEXT,
        userName TEXT,
        profileImage TEXT,
        imagePaths TEXT,
        caption TEXT,
        createdAt TEXT,
        likes TEXT,
        comments TEXT
      )
    ''');
  }

  // Create
  Future<void> createPost(Post post) async {
    final db = await database;

    await db.insert(
      'posts',
      {
        'postId': post.postId,
        'userId': post.userId,
        'userName': post.userName,
        'profileImage': post.profileImage,
        'imagePaths': jsonEncode(post.imagePaths),
        'caption': post.caption,
        'createdAt': post.createdAt.toIso8601String(),
        'likes': jsonEncode(post.likes),
        'comments': jsonEncode(post.comments),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read (단일 포스트)
  Future<Post?> readPost(String postId) async {
    final db = await database;

    final maps = await db.query(
      'posts',
      where: 'postId = ?',
      whereArgs: [postId],
    );

    if (maps.isEmpty) return null;

    return Post(
      postId: maps[0]['postId'] as String,
      userId: maps[0]['userId'] as String,
      userName: maps[0]['userName'] as String,
      profileImage: maps[0]['profileImage'] as String,
      imagePaths:
          List<String>.from(jsonDecode(maps[0]['imagePaths'] as String)),
      caption: maps[0]['caption'] as String,
      createdAt: DateTime.parse(maps[0]['createdAt'] as String),
      likes: List<String>.from(jsonDecode(maps[0]['likes'] as String)),
      comments: List<Map<String, dynamic>>.from(
        jsonDecode(maps[0]['comments'] as String),
      ),
    );
  }

  // Read (모든 포스트)
  Future<List<Post>> readAllPosts() async {
    final db = await database;

    final result = await db.query('posts', orderBy: 'createdAt DESC');

    return result
        .map((map) => Post(
              postId: map['postId'] as String,
              userId: map['userId'] as String,
              userName: map['userName'] as String,
              profileImage: map['profileImage'] as String,
              imagePaths:
                  List<String>.from(jsonDecode(map['imagePaths'] as String)),
              caption: map['caption'] as String,
              createdAt: DateTime.parse(map['createdAt'] as String),
              likes: List<String>.from(jsonDecode(map['likes'] as String)),
              comments: List<Map<String, dynamic>>.from(
                jsonDecode(map['comments'] as String),
              ),
            ))
        .toList();
  }

  // Update
  Future<void> updatePost(Post post) async {
    final db = await database;

    await db.update(
      'posts',
      {
        'userId': post.userId,
        'userName': post.userName,
        'profileImage': post.profileImage,
        'imagePaths': jsonEncode(post.imagePaths),
        'caption': post.caption,
        'createdAt': post.createdAt.toIso8601String(),
        'likes': jsonEncode(post.likes),
        'comments': jsonEncode(post.comments),
      },
      where: 'postId = ?',
      whereArgs: [post.postId],
    );
  }

  // Delete
  Future<void> deletePost(String postId) async {
    final db = await database;

    await db.delete(
      'posts',
      where: 'postId = ?',
      whereArgs: [postId],
    );
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
