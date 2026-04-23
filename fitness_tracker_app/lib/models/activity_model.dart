class ActivityModel {
  final int? id;
  final String userId;
  final String type; // e.g., 'Running', 'Walking', 'Cycling', 'Weightlifting'
  final int durationMinutes;
  final int caloriesBurned;
  final int? steps;
  final DateTime date;

  ActivityModel({
    this.id,
    required this.userId,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.steps,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'steps': steps,
      'date': date.toIso8601String(),
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      userId: map['userId'],
      type: map['type'],
      durationMinutes: map['durationMinutes'],
      caloriesBurned: map['caloriesBurned'],
      steps: map['steps'],
      date: DateTime.parse(map['date']),
    );
  }
}
