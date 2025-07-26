class NotToDo {
  final int? id;
  final String name;
  final int? goalDays;
  final int currentStreak;
  final DateTime? lastCheckedDate;
  final int? notificationId;
  final DateTime createdAt;

  NotToDo({
    this.id,
    required this.name,
    this.goalDays,
    this.currentStreak = 0,
    this.lastCheckedDate,
    this.notificationId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'goal_days': goalDays,
        'current_streak': currentStreak,
        'last_checked_date': lastCheckedDate?.toIso8601String(),
        'notification_id': notificationId,
        'created_at': createdAt.toIso8601String(),
      };

  factory NotToDo.fromMap(Map<String, dynamic> map) => NotToDo(
        id: map['id'],
        name: map['name'],
        goalDays: map['goal_days'],
        currentStreak: map['current_streak'],
        lastCheckedDate: map['last_checked_date'] != null ? DateTime.parse(map['last_checked_date']) : null,
        notificationId: map['notification_id'],
        createdAt: DateTime.parse(map['created_at']),
      );

  NotToDo copyWith({
    int? id,
    String? name,
    int? goalDays,
    int? currentStreak,
    DateTime? lastCheckedDate,
    int? notificationId,
    DateTime? createdAt,
  }) {
    return NotToDo(
      id: id ?? this.id,
      name: name ?? this.name,
      goalDays: goalDays ?? this.goalDays,
      currentStreak: currentStreak ?? this.currentStreak,
      lastCheckedDate: lastCheckedDate ?? this.lastCheckedDate,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}