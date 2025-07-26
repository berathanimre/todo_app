import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TimeOfDay _reminderTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Task')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', errorText: _titleController.text.isEmpty ? 'Required' : null),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description (optional)'),
            ),
            ListTile(
              title: Text('Due Date: ${DateFormat.yMMMd().format(_dueDate)}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                  });
                }
              },
            ),
            ListTile(
              title: Text('Reminder Time: ${_reminderTime.format(context)}'),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (time != null) {
                  setState(() {
                    _reminderTime = time;
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  final task = Task(
                    title: _titleController.text,
                    description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                    dueDate: _dueDate,
                    reminderTime: '${_reminderTime.hour}:${_reminderTime.minute}',
                    createdAt: DateTime.now(),
                  );
                  await Provider.of<TaskProvider>(context, listen: false).addTask(task);
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