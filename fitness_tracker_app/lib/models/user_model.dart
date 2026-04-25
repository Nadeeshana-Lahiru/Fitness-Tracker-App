class UserModel {
  final String id;
  final String name;
  final String email;
  final String? passwordHash;
  final String? photoUrl;
  final String? age;
  final String? mobileNumber;
  final String? height;
  final String? weight;
  final int dailyStepGoal;
  final int dailyCalorieGoal;
  final int dailyWaterGoalMl;
  final int dailyActiveMinGoal;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.passwordHash,
    this.photoUrl,
    this.age,
    this.mobileNumber,
    this.height,
    this.weight,
    this.dailyStepGoal = 10000,
    this.dailyCalorieGoal = 2000,
    this.dailyWaterGoalMl = 2000,
    this.dailyActiveMinGoal = 30,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Legacy compat: expose password as getter (for migration)
  String? get password => passwordHash;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password_hash': passwordHash,
    'photo_url': photoUrl,
    'age': age,
    'mobile_number': mobileNumber,
    'height': height,
    'weight': weight,
    'daily_step_goal': dailyStepGoal,
    'daily_calorie_goal': dailyCalorieGoal,
    'daily_water_goal_ml': dailyWaterGoalMl,
    'daily_active_min_goal': dailyActiveMinGoal,
    'created_at': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'],
    name: m['name'],
    email: m['email'],
    passwordHash: m['password_hash'],
    photoUrl: m['photo_url'],
    age: m['age'],
    mobileNumber: m['mobile_number'],
    height: m['height'],
    weight: m['weight'],
    dailyStepGoal: m['daily_step_goal'] ?? 10000,
    dailyCalorieGoal: m['daily_calorie_goal'] ?? 2000,
    dailyWaterGoalMl: m['daily_water_goal_ml'] ?? 2000,
    dailyActiveMinGoal: m['daily_active_min_goal'] ?? 30,
    createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
  );

  UserModel copyWith({
    String? name,
    String? passwordHash,
    String? photoUrl,
    String? age,
    String? mobileNumber,
    String? height,
    String? weight,
    int? dailyStepGoal,
    int? dailyCalorieGoal,
    int? dailyWaterGoalMl,
    int? dailyActiveMinGoal,
  }) => UserModel(
    id: id,
    name: name ?? this.name,
    email: email,
    passwordHash: passwordHash ?? this.passwordHash,
    photoUrl: photoUrl ?? this.photoUrl,
    age: age ?? this.age,
    mobileNumber: mobileNumber ?? this.mobileNumber,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
    dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
    dailyWaterGoalMl: dailyWaterGoalMl ?? this.dailyWaterGoalMl,
    dailyActiveMinGoal: dailyActiveMinGoal ?? this.dailyActiveMinGoal,
    createdAt: createdAt,
  );
}
