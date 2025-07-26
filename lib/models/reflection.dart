class Reflection {
  final int? id;
  final int taskId;
  final String? reflection;
  final DateTime createdAt;

  Reflection({this.id, required this.taskId, this.reflection, required this.createdAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'task_id': taskId,
        'reflection': reflection,
        'created_at': createdAt.toIso8601String(),
      };

  factory Reflection.fromMap(Map<String, dynamic> map) => Reflection(
        id: map['id'],
        taskId: map['task_id'],
        reflection: map['reflection'],
        createdAt: DateTime.parse(map['created_at']),
      );

  Reflection copyWith({int? id, int? taskId, String? reflection, DateTime? createdAt}) {
    return Reflection(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      reflection: reflection ?? this.reflection,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}