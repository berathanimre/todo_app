class Milestone {
  final int? id;
  final int notToDoId;
  final int milestoneDays;
  final DateTime? achievedAt;

  Milestone({this.id, required this.notToDoId, required this.milestoneDays, this.achievedAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'not_to_do_id': notToDoId,
        'milestone_days': milestoneDays,
        'achieved_at': achievedAt?.toIso8601String(),
      };

  factory Milestone.fromMap(Map<String, dynamic> map) => Milestone(
        id: map['id'],
        notToDoId: map['not_to_do_id'],
        milestoneDays: map['milestone_days'],
        achievedAt: map['achieved_at'] != null ? DateTime.parse(map['achieved_at']) : null,
      );

  Milestone copyWith({int? id, int? notToDoId, int? milestoneDays, DateTime? achievedAt}) {
    return Milestone(
      id: id ?? this.id,
      notToDoId: notToDoId ?? this.notToDoId,
      milestoneDays: milestoneDays ?? this.milestoneDays,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }
}