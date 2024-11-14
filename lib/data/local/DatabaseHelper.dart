import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_team2/data/models/usermodel.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users(
      uid TEXT PRIMARY KEY,
      displayName TEXT,
      email TEXT,
      followers TEXT,
      following TEXT,
      photoURL TEXT
    )
    ''');
  }

  // 데이터 저장
  Future<void> insertUser(UserModel user) async {
    final db = await instance.database;
    await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 모든 사용자 정보 가져오기
  Future<List<UserModel>> getUsers() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  // 사용자 삭제
  Future<void> deleteUser(String uid) async {
    final db = await instance.database;
    await db.delete('users', where: 'uid = ?', whereArgs: [uid]);
  }
}
