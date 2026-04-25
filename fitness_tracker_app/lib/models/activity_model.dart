class ActivityModel {
  final int? id;
  final String userId;
  final String type;
  final int durationMinutes;
  final int caloriesBurned;
  final int steps;
  final String? notes;
  final DateTime date;

  ActivityModel({
    this.id,
    required this.userId,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.steps = 0,
    this.notes,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'type': type,
    'duration_minutes': durationMinutes,
    'calories_burned': caloriesBurned,
    'steps': steps,
    'notes': notes,
    'date': date.toIso8601String(),
  };

  factory ActivityModel.fromMap(Map<String, dynamic> m) => ActivityModel(
    id: m['id'],
    userId: m['user_id'],
    type: m['type'],
    durationMinutes: m['duration_minutes'],
    caloriesBurned: m['calories_burned'],
    steps: m['steps'] ?? 0,
    notes: m['notes'],
    date: DateTime.parse(m['date']),
  );
}
