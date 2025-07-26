import 'package:flutter/material.dart';
import '../models/not_to_do.dart';
import '../models/milestone.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class NotToDoProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<NotToDo> _notToDoItems = [];

  List<NotToDo> get notToDoItems => _notToDoItems;

  Future<void> loadNotToDoItems() async {
    _notToDoItems = await _dbService.getNotToDoItems();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var item in _notToDoItems) {
      if (item.lastCheckedDate != null) {
        final lastChecked = DateTime(item.lastCheckedDate!.year, item.lastCheckedDate!.month, item.lastCheckedDate!.day);
        if (lastChecked.isBefore(today.subtract(Duration(days: 1)))) {
          final notificationId = (item.id ?? DateTime.now().millisecondsSinceEpoch) % 1000000 + 1000;
          await NotificationService.scheduleNotToDoNotification(item, notificationId);
          await _dbService.updateNotToDo(item.copyWith(notificationId: notificationId));
        }
      }
    }
    notifyListeners();
  }

  Future<void> addNotToDo(NotToDo notToDo) async {
    final id = await _dbService.insertNotToDo(notToDo);
    for (var days in [7, 14, 30, 60, 100]) {
      await _dbService.insertMilestone(Milestone(notToDoId: id, milestoneDays: days));
    }
    await loadNotToDoItems();
  }

  Future<void> updateNotToDo(NotToDo notToDo, {bool resetStreak = false}) async {
    if (notToDo.notificationId != null) {
      await NotificationService.cancelNotification(notToDo.notificationId!);
    }
    final updated = notToDo.copyWith(
      currentStreak: resetStreak ? 0 : notToDo.currentStreak,
      lastCheckedDate: resetStreak ? null : notToDo.lastCheckedDate,
      notificationId: null,
    );
    await _dbService.updateNotToDo(updated);
    await loadNotToDoItems();
  }

  Future<void> checkNotToDo(int id) async {
    final item = _notToDoItems.firstWhere((i) => i.id == id);
    if (item.notificationId != null) {
      await NotificationService.cancelNotification(item.notificationId!);
    }
    final newStreak = item.currentStreak + 1;
    final updated = item.copyWith(
      currentStreak: newStreak,
      lastCheckedDate: DateTime.now(),
      notificationId: null,
    );
    await _dbService.updateNotToDo(updated);
    final milestones = await _dbService.getMilestonesByNotToDoId(id);
    for (var milestone in milestones) {
      if (newStreak >= milestone.milestoneDays && milestone.achievedAt == null) {
        await _dbService.insertMilestone(milestone.copyWith(achievedAt: DateTime.now()));
      }
    }
    await loadNotToDoItems();
  }

  Future<void> deleteNotToDo(int id) async {
    final item = _notToDoItems.firstWhere((i) => i.id == id, orElse: () => NotToDo(id: id, name: '', createdAt: DateTime.now()));
    if (item.notificationId != null) {
      await NotificationService.cancelNotification(item.notificationId!);
    }
    await _dbService.deleteNotToDo(id);
    await loadNotToDoItems();
  }
}