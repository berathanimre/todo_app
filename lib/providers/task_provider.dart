import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Task> _tasks = [];
  DateTime _selectedDate = DateTime.now();

  List<Task> get tasks => _tasks;
  DateTime get selectedDate => _selectedDate;

  Future<void> loadTasks(DateTime date) async {
    _selectedDate = date;
    _tasks = await _dbService.getTasksByDate(date);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final id = await _dbService.insertTask(task);
    final notificationId = (id ?? DateTime.now().millisecondsSinceEpoch) % 1000000;
    await NotificationService.scheduleTaskNotification(task, notificationId);
    await _dbService.updateTask(task.copyWith(id: id, notificationId: notificationId));
    await loadTasks(task.dueDate);
  }

  Future<void> updateTask(Task task) async {
    if (task.notificationId != null) {
      await NotificationService.cancelNotification(task.notificationId!);
    }
    if (!task.isCompleted) {
      final notificationId = (task.id ?? DateTime.now().millisecondsSinceEpoch) % 1000000;
      await NotificationService.scheduleTaskNotification(task, notificationId);
      await _dbService.updateTask(task.copyWith(notificationId: notificationId));
    } else {
      await _dbService.updateTask(task);
    }
    await loadTasks(task.dueDate);
  }

  Future<void> deleteTask(int id, DateTime dueDate) async {
    final task = _tasks.firstWhere(
          (t) => t.id == id,
      orElse: () => Task(
        id: id,
        title: '',
        dueDate: dueDate,
        reminderTime: '',
        createdAt: DateTime.now(),
      ),
    );
    if (task.notificationId != null) {
      await NotificationService.cancelNotification(task.notificationId!);
    }
    await _dbService.deleteTask(id);
    await loadTasks(dueDate);
  }
}