class WorkoutModel {
  final int? id;
  final String userId;
  final String name;
  final String? description;
  final String category;
  final int estimatedMinutes;
  final bool isPreset;
  final DateTime createdAt;
  final List<WorkoutExerciseModel> exercises;

  WorkoutModel({
    this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.category,
    this.estimatedMinutes = 30,
    this.isPreset = false,
    DateTime? createdAt,
    this.exercises = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'name': name,
    'description': description,
    'category': category,
    'estimated_minutes': estimatedMinutes,
    'is_preset': isPreset,
    'created_at': createdAt.toIso8601String(),
  };

  factory WorkoutModel.fromMap(Map<String, dynamic> m, {List<WorkoutExerciseModel> exercises = const []}) =>
      WorkoutModel(
        id: m['id'],
        userId: m['user_id'],
        name: m['name'],
        description: m['description'],
        category: m['category'],
        estimatedMinutes: m['estimated_minutes'] ?? 30,
        isPreset: m['is_preset'] ?? false,
        createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
        exercises: exercises,
      );
}

class WorkoutExerciseModel {
  final int? id;
  final int workoutId;
  final String exerciseName;
  final int sets;
  final int reps;
  final int restSeconds;
  final String? notes;
  final int orderIndex;
  bool isCompleted;

  WorkoutExerciseModel({
    this.id,
    required this.workoutId,
    required this.exerciseName,
    this.sets = 3,
    this.reps = 10,
    this.restSeconds = 60,
    this.notes,
    required this.orderIndex,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'workout_id': workoutId,
    'exercise_name': exerciseName,
    'sets': sets,
    'reps': reps,
    'rest_seconds': restSeconds,
    'notes': notes,
    'order_index': orderIndex,
  };

  factory WorkoutExerciseModel.fromMap(Map<String, dynamic> m) => WorkoutExerciseModel(
    id: m['id'],
    workoutId: m['workout_id'],
    exerciseName: m['exercise_name'],
    sets: m['sets'] ?? 3,
    reps: m['reps'] ?? 10,
    restSeconds: m['rest_seconds'] ?? 60,
    notes: m['notes'],
    orderIndex: m['order_index'],
  );
}

class WorkoutSessionModel {
  final int? id;
  final String userId;
  final int workoutId;
  final int durationMinutes;
  final int caloriesBurned;
  final String? notes;
  final DateTime completedAt;

  WorkoutSessionModel({
    this.id,
    required this.userId,
    required this.workoutId,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.notes,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'workout_id': workoutId,
    'duration_minutes': durationMinutes,
    'calories_burned': caloriesBurned,
    'notes': notes,
    'completed_at': completedAt.toIso8601String(),
  };

  factory WorkoutSessionModel.fromMap(Map<String, dynamic> m) => WorkoutSessionModel(
    id: m['id'],
    userId: m['user_id'],
    workoutId: m['workout_id'],
    durationMinutes: m['duration_minutes'],
    caloriesBurned: m['calories_burned'],
    notes: m['notes'],
    completedAt: DateTime.parse(m['completed_at']),
  );
}
