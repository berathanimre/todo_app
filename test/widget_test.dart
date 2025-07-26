import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/not_to_do_provider.dart';
import 'package:todo_app/providers/settings_provider.dart';

void main() {
  testWidgets('TodoApp builds without crashing', (WidgetTester tester) async {
    // Build the app with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => NotToDoProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ],
        child: TodoApp(),
      ),
    );

    // Verify that the main screen is displayed
    expect(find.byType(TodoApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}