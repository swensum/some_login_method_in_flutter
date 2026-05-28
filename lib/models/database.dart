import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('test.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        security_question TEXT,
        security_answer TEXT
      )
    ''');
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // ================= INSERT USER =================
  Future<int> createUser(UserModel user) async {
    try {
      debugPrint('📝 Creating user: ${user.email}');

      final db = await database;
      bool emailExists = await isEmailExists(user.email);
      if (emailExists) {
        throw Exception(
          'Email already registered. Please use a different email or login.',
        );
      }
      int result = await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ User created with id: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      rethrow;
    }
  }

  // ================= GET ALL USERS =================
  Future<List<UserModel>> getUsers() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  // ================= LOGIN CHECK =================
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // ================= UPDATE USER =================
  Future<int> updateUser({
    required int id,
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'name': name, 'email': email, 'password': password},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= UPDATE PASSWORD =================
  Future<bool> updatePassword(String email, String newPassword) async {
    final db = await database;
    int result = await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
    return result > 0;
  }
  // ================= UPDATE PASSWORD =================
 Future<String?> getSecurityQuestion(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['security_question'],
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first['security_question'] as String?;
    }
    return null;
  }
  Future<bool> verifySecurityAnswer(String email, String answer) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['security_answer'],
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
    final storedAnswer = result.first['security_answer'] as String?;
    // Case insensitive comparison
    return storedAnswer?.toLowerCase() == answer.trim().toLowerCase();
  }
  return false;
}
  // ================= DELETE USER =================
  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
