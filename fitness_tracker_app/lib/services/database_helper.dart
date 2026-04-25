import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../models/workout_model.dart';
import '../models/health_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  final _supabase = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // USER DAO
  // ─────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    await _supabase.from('users').upsert(user.toMap());
  }

  Future<UserModel?> getUserById(String id) async {
    final res = await _supabase.from('users').select().eq('id', id).maybeSingle();
    return res != null ? UserModel.fromMap(res) : null;
  }

  Future<UserModel?> getUser(String id) => getUserById(id);

  Future<UserModel?> getUserByEmail(String email) async {
    final res = await _supabase.from('users').select().eq('email', email).maybeSingle();
    return res != null ? UserModel.fromMap(res) : null;
  }

  Future<void> updateUserGoals(String userId, {
    int? dailyStepGoal,
    int? dailyCalorieGoal,
    int? dailyWaterGoalMl,
    int? dailyActiveMinGoal,
  }) async {
    final updates = <String, dynamic>{};
    if (dailyStepGoal != null) updates['daily_step_goal'] = dailyStepGoal;
    if (dailyCalorieGoal != null) updates['daily_calorie_goal'] = dailyCalorieGoal;
    if (dailyWaterGoalMl != null) updates['daily_water_goal_ml'] = dailyWaterGoalMl;
    if (dailyActiveMinGoal != null) updates['daily_active_min_goal'] = dailyActiveMinGoal;
    if (updates.isNotEmpty) {
      await _supabase.from('users').update(updates).eq('id', userId);
    }
  }

  // ─────────────────────────────────────────────
  // ACTIVITY DAO
  // ─────────────────────────────────────────────

  Future<int> insertActivity(ActivityModel a) async {
    final res = await _supabase.from('activities').insert(a.toMap()).select('id').single();
    return res['id'] as int;
  }

  Future<void> updateActivity(ActivityModel a) async {
    await _supabase.from('activities').update(a.toMap()).eq('id', a.id as Object);
  }

  Future<int> deleteActivity(int id) async {
    await _supabase.from('activities').delete().eq('id', id);
    return id;
  }

  Future<List<ActivityModel>> getActivities(String userId) async {
    final res = await _supabase.from('activities')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    return res.map((e) => ActivityModel.fromMap(e)).toList();
  }

  Future<List<ActivityModel>> getActivitiesInRange(String userId, DateTime from, DateTime to) async {
    final res = await _supabase.from('activities')
        .select()
        .eq('user_id', userId)
        .gte('date', from.toIso8601String())
        .lte('date', to.toIso8601String())
        .order('date', ascending: false);
    return res.map((e) => ActivityModel.fromMap(e)).toList();
  }

  // ─────────────────────────────────────────────
  // WORKOUT DAO
  // ─────────────────────────────────────────────

  Future<int> insertWorkout(WorkoutModel w) async {
    final res = await _supabase.from('workouts').insert(w.toMap()).select('id').single();
    final id = res['id'] as int;
    
    for (final ex in w.exercises) {
      await _supabase.from('workout_exercises').insert(WorkoutExerciseModel(
        workoutId: id,
        exerciseName: ex.exerciseName,
        sets: ex.sets,
        reps: ex.reps,
        restSeconds: ex.restSeconds,
        notes: ex.notes,
        orderIndex: ex.orderIndex,
      ).toMap());
    }
    return id;
  }

  Future<List<WorkoutModel>> getWorkouts(String userId) async {
    final res = await _supabase.from('workouts')
        .select('*, workout_exercises(*)')
        .or('user_id.eq.$userId,is_preset.eq.true')
        .order('created_at', ascending: false);
    
    return res.map((row) {
      final exercisesList = (row['workout_exercises'] as List?) ?? [];
      exercisesList.sort((a, b) => (a['order_index'] as int).compareTo(b['order_index'] as int));
      final exercises = exercisesList.map((e) => WorkoutExerciseModel.fromMap(e as Map<String, dynamic>)).toList();
      return WorkoutModel.fromMap(row, exercises: exercises);
    }).toList();
  }

  Future<void> deleteWorkout(int id) async {
    await _supabase.from('workouts').delete().eq('id', id);
  }

  Future<int> insertWorkoutSession(WorkoutSessionModel s) async {
    final res = await _supabase.from('workout_sessions').insert(s.toMap()).select('id').single();
    return res['id'] as int;
  }

  Future<List<WorkoutSessionModel>> getWorkoutSessions(String userId) async {
    final res = await _supabase.from('workout_sessions')
        .select()
        .eq('user_id', userId)
        .order('completed_at', ascending: false);
    return res.map((e) => WorkoutSessionModel.fromMap(e)).toList();
  }

  // ─────────────────────────────────────────────
  // MEAL DAO
  // ─────────────────────────────────────────────

  Future<int> insertMealLog(MealLogModel m) async {
    final res = await _supabase.from('meal_logs').insert(m.toMap()).select('id').single();
    return res['id'] as int;
  }

  Future<void> deleteMealLog(int id) async {
    await _supabase.from('meal_logs').delete().eq('id', id);
  }

  Future<List<MealLogModel>> getMealLogs(String userId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final res = await _supabase.from('meal_logs')
        .select()
        .eq('user_id', userId)
        .gte('logged_at', start.toIso8601String())
        .lt('logged_at', end.toIso8601String())
        .order('logged_at', ascending: true);
    return res.map((e) => MealLogModel.fromMap(e)).toList();
  }

  // ─────────────────────────────────────────────
  // WATER DAO
  // ─────────────────────────────────────────────

  Future<int> insertWaterLog(WaterLogModel w) async {
    final res = await _supabase.from('water_logs').insert(w.toMap()).select('id').single();
    return res['id'] as int;
  }

  Future<void> deleteWaterLog(int id) async {
    await _supabase.from('water_logs').delete().eq('id', id);
  }

  Future<List<WaterLogModel>> getWaterLogs(String userId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final res = await _supabase.from('water_logs')
        .select()
        .eq('user_id', userId)
        .gte('logged_at', start.toIso8601String())
        .lt('logged_at', end.toIso8601String())
        .order('logged_at', ascending: true);
    return res.map((e) => WaterLogModel.fromMap(e)).toList();
  }

  Future<int> getTodayWaterMl(String userId) async {
    final logs = await getWaterLogs(userId, DateTime.now());
    return logs.fold<int>(0, (sum, l) => sum + l.amountMl);
  }

  // ─────────────────────────────────────────────
  // SLEEP DAO
  // ─────────────────────────────────────────────

  Future<int> insertSleepLog(SleepLogModel s) async {
    final res = await _supabase.from('sleep_logs').insert(s.toMap()).select('id').single();
    return res['id'] as int;
  }

  Future<List<SleepLogModel>> getSleepLogs(String userId, {int limit = 7}) async {
    final res = await _supabase.from('sleep_logs')
        .select()
        .eq('user_id', userId)
        .order('bed_time', ascending: false)
        .limit(limit);
    return res.map((e) => SleepLogModel.fromMap(e)).toList();
  }

  Future<void> deleteSleepLog(int id) async {
    await _supabase.from('sleep_logs').delete().eq('id', id);
  }

  // ─────────────────────────────────────────────
  // BODY METRICS DAO
  // ─────────────────────────────────────────────

  Future<int> insertBodyMetric(BodyMetricModel m) async {
    final res = await _supabase.from('body_metrics').insert(m.toMap()).select('id').single();
    return res['id'] as int;
  }

  Future<List<BodyMetricModel>> getBodyMetrics(String userId, {int limit = 30}) async {
    final res = await _supabase.from('body_metrics')
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false)
        .limit(limit);
    return res.map((e) => BodyMetricModel.fromMap(e)).toList();
  }

  Future<BodyMetricModel?> getLatestBodyMetric(String userId) async {
    final metrics = await getBodyMetrics(userId, limit: 1);
    return metrics.isEmpty ? null : metrics.first;
  }

  // ─────────────────────────────────────────────
  // ACHIEVEMENTS DAO
  // ─────────────────────────────────────────────

  Future<int> insertAchievement(AchievementModel a) async {
    final res = await _supabase.from('achievements').insert(a.toMap()).select('id').single();
    return res['id'] as int;
  }

  Future<List<AchievementModel>> getAchievements(String userId) async {
    final res = await _supabase.from('achievements')
        .select()
        .eq('user_id', userId)
        .order('earned_at', ascending: false);
    return res.map((e) => AchievementModel.fromMap(e)).toList();
  }

  Future<bool> hasBadge(String userId, String badgeKey) async {
    final res = await _supabase.from('achievements')
        .select('id')
        .eq('user_id', userId)
        .eq('badge_key', badgeKey);
    return res.isNotEmpty;
  }

  // ─────────────────────────────────────────────
  // DAILY STEPS DAO
  // ─────────────────────────────────────────────

  Future<void> upsertDailySteps(String userId, int steps, double distanceKm) async {
    final today = DateTime.now();
    final dateStr = DateTime(today.year, today.month, today.day).toIso8601String();
    
    final existing = await _supabase.from('daily_step_counts')
        .select('id')
        .eq('user_id', userId)
        .eq('date', dateStr);
        
    if (existing.isEmpty) {
      await _supabase.from('daily_step_counts').insert({
        'user_id': userId,
        'steps': steps,
        'distance_km': distanceKm,
        'date': dateStr,
      });
    } else {
      await _supabase.from('daily_step_counts').update({
        'steps': steps,
        'distance_km': distanceKm,
      }).eq('id', existing.first['id'] as Object);
    }
  }

  Future<List<DailyStepCountModel>> getWeeklySteps(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final res = await _supabase.from('daily_step_counts')
        .select()
        .eq('user_id', userId)
        .gte('date', DateTime(weekAgo.year, weekAgo.month, weekAgo.day).toIso8601String())
        .order('date', ascending: true);
    return res.map((e) => DailyStepCountModel.fromMap(e)).toList();
  }

  Future<int> getTodaySteps(String userId) async {
    final today = DateTime.now();
    final dateStr = DateTime(today.year, today.month, today.day).toIso8601String();
    final res = await _supabase.from('daily_step_counts')
        .select('steps')
        .eq('user_id', userId)
        .eq('date', dateStr);
    if (res.isEmpty) return 0;
    return res.first['steps'] as int;
  }
}
