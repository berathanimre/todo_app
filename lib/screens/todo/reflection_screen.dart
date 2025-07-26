import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/reflection.dart';

class ReflectionScreen extends StatefulWidget {
  final int taskId;

  ReflectionScreen({required this.taskId});

  @override
  _ReflectionScreenState createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final _reflectionController = TextEditingController();
  Reflection? _reflection;

  @override
  void initState() {
    super.initState();
    _loadReflection();
  }

  Future<void> _loadReflection() async {
    final reflection = await DatabaseService().getReflectionByTaskId(widget.taskId);
    if (reflection != null) {
      setState(() {
        _reflection = reflection;
        _reflectionController.text = reflection.reflection ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add/Edit Reflection')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _reflectionController,
              decoration: InputDecoration(labelText: 'How did you feel? (optional)'),
              maxLines: 4,
            ),
            ElevatedButton(
              onPressed: () async {
                final reflection = Reflection(
                  id: _reflection?.id,
                  taskId: widget.taskId,
                  reflection: _reflectionController.text.isEmpty ? null : _reflectionController.text,
                  createdAt: DateTime.now(),
                );
                final dbService = DatabaseService();
                if (_reflection == null) {
                  await dbService.insertReflection(reflection);
                } else {
                  await dbService.updateReflection(reflection);
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}