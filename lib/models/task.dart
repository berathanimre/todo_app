class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String reminderTime;
  final bool isCompleted;
  final int? notificationId;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.reminderTime,
    this.isCompleted = false,
    this.notificationId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'reminder_time': reminderTime,
        'is_completed': isCompleted ? 1 : 0,
        'notification_id': notificationId,
        'created_at': createdAt.toIso8601String(),
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        dueDate: DateTime.parse(map['due_date']),
        reminderTime: map['reminder_time'],
        isCompleted: map['is_completed'] == 1,
        notificationId: map['notification_id'],
        createdAt: DateTime.parse(map['created_at']),
      );

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? reminderTime,
    bool? isCompleted,
    int? notificationId,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}