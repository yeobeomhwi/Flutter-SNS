import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/usermodel.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'users.db'; // 데이터베이스 이름
  static const String _tableName = 'users'; // 테이블 이름

  // 데이터베이스 열기
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _dbName); // 데이터베이스 파일 경로

    return openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $_tableName (
      uid TEXT PRIMARY KEY,
      displayName TEXT,
      email TEXT,
      photoURL TEXT
    )
    ''');
  }

  // 데이터베이스 버전 업그레이드 처리
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN followers TEXT;');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN following TEXT;');
    }
  }

  // UserModel 삽입
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert(
      _tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 특정 사용자 한 명을 조회하는 함수
  Future<UserModel?> getUser(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null; // 사용자가 없으면 null 반환
    }
  }

  // 모든 사용자 조회
  Future<List<UserModel>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }

  // 사용자 업데이트
  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      _tableName,
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  // 사용자 삭제
  Future<int> deleteUser(String uid) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }
}
