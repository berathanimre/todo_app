import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/database_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _snoozeDuration = 15;
  String _themeMode = 'light';
  String _backupFrequency = 'none';
  bool _cloudSyncEnabled = false;

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  int get snoozeDuration => _snoozeDuration;
  String get themeMode => _themeMode;
  String get backupFrequency => _backupFrequency;
  bool get cloudSyncEnabled => _cloudSyncEnabled;

  Future<void> loadSettings() async {
    _soundEnabled = await _settingsService.getNotificationSound();
    _vibrationEnabled = await _settingsService.getNotificationVibration();
    _snoozeDuration = await _settingsService.getSnoozeDuration();
    _themeMode = await _settingsService.getThemeMode();
    _backupFrequency = await _settingsService.getBackupFrequency();
    _cloudSyncEnabled = await _settingsService.getCloudSyncEnabled();
    notifyListeners();
  }

  Future<void> updateSetting(String key, dynamic value) async {
    await _settingsService.saveSetting(key, value);
    await loadSettings();
  }

  Future<void> exportData() async {
    await _settingsService.exportData(DatabaseService());
  }

  Future<void> importData() async {
    await _settingsService.importData(DatabaseService());
    notifyListeners();
  }

  Future<void> clearData() async {
    await _settingsService.clearData(DatabaseService());
    notifyListeners();
  }
}