import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task; // Add task parameter for editing

  AddTaskScreen({this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TimeOfDay _reminderTime = TimeOfDay.now();
  bool _isTitleEmpty = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _dueDate = widget.task!.dueDate;
      _reminderTime = TimeOfDay(
        hour: int.parse(widget.task!.reminderTime.split(':')[0]),
        minute: int.parse(widget.task!.reminderTime.split(':')[1]),
      );
    }
    _titleController.addListener(() {
      setState(() {
        _isTitleEmpty = _titleController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? 'Add Task' : 'Edit Task')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: _isTitleEmpty ? 'Required' : null,
              ),
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
              onPressed: _isLoading
                  ? null
                  : () async {
                if (_titleController.text.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });
                  final task = Task(
                    id: widget.task?.id,
                    title: _titleController.text,
                    description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                    dueDate: _dueDate,
                    reminderTime: '${_reminderTime.hour}:${_reminderTime.minute}',
                    isCompleted: widget.task?.isCompleted ?? false,
                    notificationId: widget.task?.notificationId,
                    createdAt: widget.task?.createdAt ?? DateTime.now(),
                  );
                  final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                  if (widget.task == null) {
                    await taskProvider.addTask(task);
                  } else {
                    await taskProvider.updateTask(task);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(widget.task == null ? 'Task added' : 'Task updated')),
                  );
                  Navigator.pop(context, _dueDate); // Return dueDate to refresh HomeScreen
                  setState(() {
                    _isLoading = false;
                  });
                } else {
                  setState(() {
                    _isTitleEmpty = true;
                  });
                }
              },
              child: _isLoading ? CircularProgressIndicator() : Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}