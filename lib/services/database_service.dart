import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'tasks';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        dueDate INTEGER,
        completedAt INTEGER
      )
    ''');
  }

  static Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  static Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(_tableName, task.toMap());
  }

  static Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      _tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }
}