import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'chatbot_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<int> signUp(User user) async {
    final db = await database;
    final existingUsers = await db.query('users', where: 'email = ?', whereArgs: [user.email]);
    if (existingUsers.isNotEmpty) {
      return -1;
    }
    
    final hashedPassword = _hashPassword(user.password);
    final userWithHashedPassword = User(email: user.email, password: hashedPassword);
    
    return await db.insert('users', userWithHashedPassword.toMap());
  }

  Future<User?> login(String email, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );

    if (maps.isNotEmpty) {
      return User(
        id: maps[0]['id'],
        email: maps[0]['email'],
        password: maps[0]['password'],
      );
    }
    return null;
  }
}