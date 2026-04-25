class MealLogModel {
  final int? id;
  final String userId;
  final String mealType; // breakfast, lunch, dinner, snack
  final String foodName;
  final String? barcode;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingGrams;
  final DateTime loggedAt;

  MealLogModel({
    this.id,
    required this.userId,
    required this.mealType,
    required this.foodName,
    this.barcode,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.servingGrams = 100,
    required this.loggedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'meal_type': mealType,
    'food_name': foodName,
    'barcode': barcode,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'serving_grams': servingGrams,
    'logged_at': loggedAt.toIso8601String(),
  };

  factory MealLogModel.fromMap(Map<String, dynamic> m) => MealLogModel(
    id: m['id'],
    userId: m['user_id'],
    mealType: m['meal_type'],
    foodName: m['food_name'],
    barcode: m['barcode'],
    calories: (m['calories'] as num).toDouble(),
    protein: (m['protein'] as num? ?? 0).toDouble(),
    carbs: (m['carbs'] as num? ?? 0).toDouble(),
    fat: (m['fat'] as num? ?? 0).toDouble(),
    servingGrams: (m['serving_grams'] as num? ?? 100).toDouble(),
    loggedAt: DateTime.parse(m['logged_at']),
  );
}

class WaterLogModel {
  final int? id;
  final String userId;
  final int amountMl;
  final DateTime loggedAt;

  WaterLogModel({
    this.id,
    required this.userId,
    required this.amountMl,
    required this.loggedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'amount_ml': amountMl,
    'logged_at': loggedAt.toIso8601String(),
  };

  factory WaterLogModel.fromMap(Map<String, dynamic> m) => WaterLogModel(
    id: m['id'],
    userId: m['user_id'],
    amountMl: m['amount_ml'],
    loggedAt: DateTime.parse(m['logged_at']),
  );
}

class SleepLogModel {
  final int? id;
  final String userId;
  final DateTime bedTime;
  final DateTime wakeTime;
  final int qualityRating; // 1-5
  final String? notes;

  SleepLogModel({
    this.id,
    required this.userId,
    required this.bedTime,
    required this.wakeTime,
    required this.qualityRating,
    this.notes,
  });

  Duration get duration => wakeTime.difference(bedTime);
  double get hoursSlept => duration.inMinutes / 60.0;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'bed_time': bedTime.toIso8601String(),
    'wake_time': wakeTime.toIso8601String(),
    'quality_rating': qualityRating,
    'notes': notes,
  };

  factory SleepLogModel.fromMap(Map<String, dynamic> m) => SleepLogModel(
    id: m['id'],
    userId: m['user_id'],
    bedTime: DateTime.parse(m['bed_time']),
    wakeTime: DateTime.parse(m['wake_time']),
    qualityRating: m['quality_rating'],
    notes: m['notes'],
  );
}

class BodyMetricModel {
  final int? id;
  final String userId;
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercent;
  final double? bmi;
  final DateTime recordedAt;

  BodyMetricModel({
    this.id,
    required this.userId,
    this.weightKg,
    this.heightCm,
    this.bodyFatPercent,
    this.bmi,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'weight_kg': weightKg,
    'height_cm': heightCm,
    'body_fat_percent': bodyFatPercent,
    'bmi': bmi,
    'recorded_at': recordedAt.toIso8601String(),
  };

  factory BodyMetricModel.fromMap(Map<String, dynamic> m) => BodyMetricModel(
    id: m['id'],
    userId: m['user_id'],
    weightKg: m['weight_kg'] != null ? (m['weight_kg'] as num).toDouble() : null,
    heightCm: m['height_cm'] != null ? (m['height_cm'] as num).toDouble() : null,
    bodyFatPercent: m['body_fat_percent'] != null ? (m['body_fat_percent'] as num).toDouble() : null,
    bmi: m['bmi'] != null ? (m['bmi'] as num).toDouble() : null,
    recordedAt: DateTime.parse(m['recorded_at']),
  );
}

class AchievementModel {
  final int? id;
  final String userId;
  final String badgeKey;
  final String title;
  final String description;
  final String iconEmoji;
  final DateTime earnedAt;

  AchievementModel({
    this.id,
    required this.userId,
    required this.badgeKey,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.earnedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'badge_key': badgeKey,
    'title': title,
    'description': description,
    'icon_emoji': iconEmoji,
    'earned_at': earnedAt.toIso8601String(),
  };

  factory AchievementModel.fromMap(Map<String, dynamic> m) => AchievementModel(
    id: m['id'],
    userId: m['user_id'],
    badgeKey: m['badge_key'],
    title: m['title'],
    description: m['description'],
    iconEmoji: m['icon_emoji'],
    earnedAt: DateTime.parse(m['earned_at']),
  );
}

class DailyStepCountModel {
  final int? id;
  final String userId;
  final int steps;
  final double distanceKm;
  final DateTime date;

  DailyStepCountModel({
    this.id,
    required this.userId,
    required this.steps,
    this.distanceKm = 0,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'steps': steps,
    'distance_km': distanceKm,
    'date': date.toIso8601String(),
  };

  factory DailyStepCountModel.fromMap(Map<String, dynamic> m) => DailyStepCountModel(
    id: m['id'],
    userId: m['user_id'],
    steps: m['steps'],
    distanceKm: (m['distance_km'] as num? ?? 0).toDouble(),
    date: DateTime.parse(m['date']),
  );
}
