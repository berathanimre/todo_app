import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/not_to_do_provider.dart';
import 'package:todo_app/providers/settings_provider.dart';
import 'package:todo_app/screens/main_screen.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Initialize timezone data
  await NotificationService.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => NotToDoProvider()),
      ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
    ],
    child: TodoApp(),
  ));
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<SettingsProvider>(context).themeMode;
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode == 'light' ? ThemeMode.light : ThemeMode.dark,
      home: MainScreen(),
    );
  }
}