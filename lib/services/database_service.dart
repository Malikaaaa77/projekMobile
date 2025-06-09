import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/favorite_model.dart';
import '../models/history_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static DatabaseService get instance => _instance;
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        profileImagePath TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
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
        addedAt INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
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
        completedAt INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE feedback(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        suggestion TEXT,
        impression TEXT,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE suggestions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        suggestion TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN fullName TEXT DEFAULT ""');
      await db.execute('ALTER TABLE users ADD COLUMN profileImagePath TEXT');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS feedback(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          rating INTEGER NOT NULL,
          suggestion TEXT,
          impression TEXT,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS suggestions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          suggestion TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // User methods
  Future<UserModel> createUser(UserModel user) async {
    final db = await database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Favorite methods
  Future<FavoriteModel> addFavorite(FavoriteModel favorite) async {
    final db = await database;
    final id = await db.insert('favorites', favorite.toMap());
    return favorite.copyWith(id: id);
  }

  Future<List<FavoriteModel>> getFavoritesByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'addedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return FavoriteModel.fromMap(maps[i]);
    });
  }

  // Add alias method for compatibility
  Future<List<FavoriteModel>> getFavoritesByUser(int userId) async {
    return await getFavoritesByUserId(userId);
  }

  Future<bool> isFavorite(int userId, String exerciseName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'userId = ? AND exerciseName = ?',
      whereArgs: [userId, exerciseName],
    );

    return maps.isNotEmpty;
  }

  Future<int> removeFavorite(int userId, String exerciseName) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'userId = ? AND exerciseName = ?',
      whereArgs: [userId, exerciseName],
    );
  }

  // History methods
  Future<HistoryModel> addHistory(HistoryModel history) async {
    final db = await database;
    final id = await db.insert('history', history.toMap());
    return history.copyWith(id: id);
  }

  Future<List<HistoryModel>> getHistoryByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'completedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return HistoryModel.fromMap(maps[i]);
    });
  }

  // Add alias method for compatibility
  Future<List<HistoryModel>> getHistoryByUser(int userId) async {
    return await getHistoryByUserId(userId);
  }

  // Feedback methods
  Future<int> saveFeedback({
    required int userId,
    required int rating,
    String? suggestion,
    String? impression,
  }) async {
    final db = await database;
    return await db.insert('feedback', {
      'userId': userId,
      'rating': rating,
      'suggestion': suggestion,
      'impression': impression,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getFeedbackByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'feedback',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  // Suggestion methods
  Future<int> addSuggestion(int userId, String suggestion) async {
    final db = await database;
    return await db.insert('suggestions', {
      'userId': userId,
      'suggestion': suggestion,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getSuggestionsByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'suggestions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  // Database utilities
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}