import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/not_to_do_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Notification Sound'),
            value: settingsProvider.soundEnabled,
            onChanged: (value) => settingsProvider.updateSetting('notification_sound', value),
          ),
          SwitchListTile(
            title: Text('Notification Vibration'),
            value: settingsProvider.vibrationEnabled,
            onChanged: (value) => settingsProvider.updateSetting('notification_vibration', value),
          ),
          ListTile(
            title: Text('Snooze Duration'),
            subtitle: Text('${settingsProvider.snoozeDuration} minutes'),
            onTap: () async {
              final durations = [5, 15, 30];
              final selected = await showDialog<int>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text('Select Snooze Duration'),
                  children: durations
                      .map((duration) => SimpleDialogOption(
                            child: Text('$duration minutes'),
                            onPressed: () => Navigator.pop(context, duration),
                          ))
                      .toList(),
                ),
              );
              if (selected != null) {
                settingsProvider.updateSetting('snooze_duration', selected.toString());
              }
            },
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: settingsProvider.themeMode == 'dark',
            onChanged: (value) => settingsProvider.updateSetting('theme_mode', value ? 'dark' : 'light'),
          ),
          ListTile(
            title: Text('Backup Frequency'),
            subtitle: Text(settingsProvider.backupFrequency),
            onTap: () async {
              final frequencies = ['none', 'daily', 'weekly'];
              final selected = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text('Select Backup Frequency'),
                  children: frequencies
                      .map((freq) => SimpleDialogOption(
                            child: Text(freq),
                            onPressed: () => Navigator.pop(context, freq),
                          ))
                      .toList(),
                ),
              );
              if (selected != null) {
                settingsProvider.updateSetting('backup_frequency', selected);
              }
            },
          ),
          SwitchListTile(
            title: Text('Cloud Sync (Future)'),
            value: settingsProvider.cloudSyncEnabled,
            onChanged: (value) => settingsProvider.updateSetting('cloud_sync_enabled', value),
          ),
          ListTile(
            title: Text('Export Data'),
            onTap: () async {
              await settingsProvider.exportData();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data exported')));
            },
          ),
          ListTile(
            title: Text('Import Data'),
            onTap: () async {
              await settingsProvider.importData();
              Provider.of<TaskProvider>(context, listen: false).loadTasks(DateTime.now());
              Provider.of<NotToDoProvider>(context, listen: false).loadNotToDoItems();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data imported')));
            },
          ),
          ListTile(
            title: Text('Clear Data'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Clear All Data'),
                  content: Text('Are you sure you want to delete all tasks and habits?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Clear'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await settingsProvider.clearData();
                Provider.of<TaskProvider>(context, listen: false).loadTasks(DateTime.now());
                Provider.of<NotToDoProvider>(context, listen: false).loadNotToDoItems();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data cleared')));
              }
            },
          ),
          ExpansionTile(
            title: Text('Privacy Information'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'All data is stored locally using SQLite. Reflections are not encrypted. '
                  'Data is not sent to external servers unless exported by you. '
                  'Cloud sync is disabled by default and can be opted out when implemented.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}