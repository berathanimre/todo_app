import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
import '../models/not_to_do.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const ios = IOSInitializationSettings();
    const initSettings = InitializationSettings(android: android);//, iOS: ios);
    await _notifications.initialize(initSettings);
    // Timezone is initialized in main.dart, so no need to call tz.initializeTimeZones() here
    tz.setLocalLocation(tz.getLocation('UTC')); // Use UTC or adjust to local timezone if needed
  }

  static Future<void> scheduleTaskNotification(Task task, int notificationId) async {
    final now = DateTime.now();
    final date = task.dueDate;
    final time = task.reminderTime.split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    final scheduledDate = tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute);
    if (scheduledDate.isAfter(now)) {
      await _notifications.zonedSchedule(
        notificationId,
        'Task Reminder: ${task.title}',
        'Time to complete your task!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails('tasks', 'Tasks', importance: Importance.high, priority: Priority.high),
          //iOS: IOSNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> scheduleNotToDoNotification(NotToDo notToDo, int notificationId) async {
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final scheduledDate = tz.TZDateTime(tz.local, tomorrow.year, tomorrow.month, tomorrow.day, 9, 0); // 9 AM next day
    await _notifications.zonedSchedule(
      notificationId,
      'Not to Do: ${notToDo.name}',
      'Did you avoid this habit yesterday? Check now.',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails('not_to_do', 'Not to Do', importance: Importance.high, priority: Priority.high),
        //iOS: IOSNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }
}
