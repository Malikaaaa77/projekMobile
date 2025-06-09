import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/favorite_model.dart';
import '../models/history_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gym_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        profileImagePath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        exerciseName TEXT NOT NULL,
        exerciseType TEXT NOT NULL,
        muscle TEXT NOT NULL,
        equipment TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        instructions TEXT NOT NULL,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        exerciseName TEXT NOT NULL,
        exerciseType TEXT NOT NULL,
        muscle TEXT NOT NULL,
        equipment TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        instructions TEXT NOT NULL,
        completedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE suggestions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        suggestion TEXT NOT NULL,
        impression TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<int> createUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Favorite operations
  Future<int> addFavorite(FavoriteModel favorite) async {
    final db = await instance.database;
    return await db.insert('favorites', favorite.toMap());
  }

  Future<List<FavoriteModel>> getFavoritesByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'addedAt DESC',
    );

    return result.map((map) => FavoriteModel.fromMap(map)).toList();
  }

  Future<int> removeFavorite(int userId, String exerciseName) async {
    final db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'userId = ? AND exerciseName = ?',
      whereArgs: [userId, exerciseName],
    );
  }

  Future<bool> isFavorite(int userId, String exerciseName) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'userId = ? AND exerciseName = ?',
      whereArgs: [userId, exerciseName],
    );
    return result.isNotEmpty;
  }

  // History operations
  Future<int> addHistory(HistoryModel history) async {
    final db = await instance.database;
    return await db.insert('history', history.toMap());
  }

  Future<List<HistoryModel>> getHistoryByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'history',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'completedAt DESC',
    );

    return result.map((map) => HistoryModel.fromMap(map)).toList();
  }

  // Suggestions operations
  Future<int> addSuggestion(int userId, String suggestion, String impression) async {
    final db = await instance.database;
    return await db.insert('suggestions', {
      'userId': userId,
      'suggestion': suggestion,
      'impression': impression,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}