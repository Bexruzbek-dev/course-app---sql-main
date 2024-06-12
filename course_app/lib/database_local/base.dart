import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('courses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';

    await db.execute('''
    CREATE TABLE courses (
      id $idType,
      title $textType,
      description $textType,
      imageUrl $textType,
      price $doubleType,
      isBought $boolType,
      isFavorite $boolType
    )
    ''');
  }

  Future<void> insertCourse(Map<String, dynamic> course) async {
    final db = await instance.database;
    await db.insert('courses', course);
  }

  Future<List<Map<String, dynamic>>> getAllCourses() async {
    final db = await instance.database;
    return await db.query('courses');
  }

  Future<void> markCourseAsBought(int id) async {
    final db = await instance.database;
    await db.update(
      'courses',
      {'isBought': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markCourseAsFavorite(int id) async {
    final db = await instance.database;
    await db.update(
      'courses',
      {'isFavorite': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getBoughtCourses() async {
    final db = await instance.database;
    return await db.query('courses', where: 'isBought = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> getFavoriteCourses() async {
    final db = await instance.database;
    return await db.query('courses', where: 'isFavorite = ?', whereArgs: [1]);
  }
}
