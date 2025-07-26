import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

import 'package:path/path.dart';

class SettingsService {
  static const _soundKey = 'notification_sound';
  static const _vibrationKey = 'notification_vibration';
  static const _snoozeKey = 'snooze_duration';
  static const _themeKey = 'theme_mode';
  static const _backupKey = 'backup_frequency';
  static const _cloudSyncKey = 'cloud_sync_enabled';

  Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Future<bool> getNotificationSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<bool> getNotificationVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  Future<int> getSnoozeDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return int.parse(prefs.getString(_snoozeKey) ?? '15');
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'light';
  }

  Future<String> getBackupFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backupKey) ?? 'none';
  }

  Future<bool> getCloudSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_cloudSyncKey) ?? false;
  }

  Future<void> exportData(DatabaseService dbService) async {
    final data = await dbService.exportData();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(join(dir.path, 'todo_backup.json'));
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> importData(DatabaseService dbService) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(join(dir.path, 'todo_backup.json'));
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString());
      await dbService.importData(data);
    }
  }

  Future<void> clearData(DatabaseService dbService) async {
    await dbService.clearData();
  }
}