import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import 'add_task_screen.dart';
import 'reflection_screen.dart';
import '../../models/task.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadTasks(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: taskProvider.selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                taskProvider.loadTasks(date);
              }
            },
          ),
        ],
      ),
      body: taskProvider.tasks.isEmpty
          ? Center(child: Text('No tasks for this date'))
          : ListView.builder(
        itemCount: taskProvider.tasks.length,
        itemBuilder: (context, index) {
          final task = taskProvider.tasks[index];
          return Card(
            child: ListTile(
              title: Text(task.title),
              subtitle: Text('${task.reminderTime} ${task.isCompleted ? '(Completed)' : ''}'),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (value) async {
                  await taskProvider.updateTask(task.copyWith(isCompleted: value ?? false));
                  if (value == true) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ReflectionScreen(taskId: task.id!)));
                  }
                },
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await taskProvider.deleteTask(task.id!, task.dueDate);
                },
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
                );
                if (result != null) {
                  taskProvider.loadTasks(result as DateTime);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen()),
          );
          if (result != null) {
            taskProvider.loadTasks(result as DateTime);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}