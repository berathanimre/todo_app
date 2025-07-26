import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/not_to_do_provider.dart';
import '../../models/not_to_do.dart';

class AddNotToDoScreen extends StatefulWidget {
  @override
  _AddNotToDoScreenState createState() => _AddNotToDoScreenState();
}

class _AddNotToDoScreenState extends State<AddNotToDoScreen> {
  final _nameController = TextEditingController();
  final _goalDaysController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Not to Do')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Habit Name', errorText: _nameController.text.isEmpty ? 'Required' : null),
            ),
            TextField(
              controller: _goalDaysController,
              decoration: InputDecoration(labelText: 'Goal Days (optional)'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  final notToDo = NotToDo(
                    name: _nameController.text,
                    goalDays: _goalDaysController.text.isEmpty ? null : int.parse(_goalDaysController.text),
                    createdAt: DateTime.now(),
                  );
                  await Provider.of<NotToDoProvider>(context, listen: false).addNotToDo(notToDo);
                  Navigator.pop(context);
                } else {
                  setState(() {}); // Trigger validation
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}