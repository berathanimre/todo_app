import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/reflection.dart';
import '../models/not_to_do.dart';
import '../models/milestone.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'todo_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            due_date TEXT NOT NULL,
            reminder_time TEXT NOT NULL,
            is_completed INTEGER NOT NULL,
            notification_id INTEGER,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE reflections (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER NOT NULL,
            reflection TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (task_id) REFERENCES tasks (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE not_to_do (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            goal_days INTEGER,
            current_streak INTEGER NOT NULL,
            last_checked_date TEXT,
            notification_id INTEGER,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE milestones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            not_to_do_id INTEGER NOT NULL,
            milestone_days INTEGER NOT NULL,
            achieved_at TEXT,
            FOREIGN KEY (not_to_do_id) REFERENCES not_to_do (id)
          )
        ''');
      },
    );
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(Duration(days: 1));
    final maps = await db.query(
      'tasks',
      where: 'due_date >= ? AND due_date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertReflection(Reflection reflection) async {
    final db = await database;
    await db.insert('reflections', reflection.toMap());
  }

  Future<Reflection?> getReflectionByTaskId(int taskId) async {
    final db = await database;
    final maps = await db.query('reflections', where: 'task_id = ?', whereArgs: [taskId]);
    return maps.isNotEmpty ? Reflection.fromMap(maps.first) : null;
  }

  Future<void> updateReflection(Reflection reflection) async {
    final db = await database;
    await db.update('reflections', reflection.toMap(), where: 'id = ?', whereArgs: [reflection.id]);
  }

  Future<int> insertNotToDo(NotToDo notToDo) async {
    final db = await database;
    return await db.insert('not_to_do', notToDo.toMap());
  }

  Future<List<NotToDo>> getNotToDoItems() async {
    final db = await database;
    final maps = await db.query('not_to_do');
    return maps.map((map) => NotToDo.fromMap(map)).toList();
  }

  Future<void> updateNotToDo(NotToDo notToDo) async {
    final db = await database;
    await db.update('not_to_do', notToDo.toMap(), where: 'id = ?', whereArgs: [notToDo.id]);
  }

  Future<void> deleteNotToDo(int id) async {
    final db = await database;
    await db.delete('not_to_do', where: 'id = ?', whereArgs: [id]);
    await db.delete('milestones', where: 'not_to_do_id = ?', whereArgs: [id]);
  }

  Future<void> insertMilestone(Milestone milestone) async {
    final db = await database;
    await db.insert('milestones', milestone.toMap());
  }

  Future<List<Milestone>> getMilestonesByNotToDoId(int notToDoId) async {
    final db = await database;
    final maps = await db.query('milestones', where: 'not_to_do_id = ?', whereArgs: [notToDoId]);
    return maps.map((map) => Milestone.fromMap(map)).toList();
  }

  Future<Map<String, List>> exportData() async {
    final db = await database;
    return {
      'tasks': await db.query('tasks'),
      'reflections': await db.query('reflections'),
      'not_to_do': await db.query('not_to_do'),
      'milestones': await db.query('milestones'),
    };
  }

  Future<void> importData(Map<String, List> data) async {
    final db = await database;
    final batch = db.batch();
    for (var table in ['tasks', 'reflections', 'not_to_do', 'milestones']) {
      batch.delete(table);
      for (var item in data[table]!) {
        batch.insert(table, item);
      }
    }
    await batch.commit();
  }

  Future<void> clearData() async {
    final db = await database;
    for (var table in ['tasks', 'reflections', 'not_to_do', 'milestones']) {
      await db.delete(table);
    }
  }
}