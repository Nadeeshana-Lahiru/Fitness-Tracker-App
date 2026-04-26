import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../models/health_models.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';

class AppProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  List<ActivityModel> _activities = [];
  List<ActivityModel> get activities => _activities;

  List<AchievementModel> _achievements = [];
  List<AchievementModel> get achievements => _achievements;

  List<WaterLogModel> _todayWaterLogs = [];
  List<WaterLogModel> get todayWaterLogs => _todayWaterLogs;
  int get todayWaterMl => _todayWaterLogs.fold(0, (s, w) => s + w.amountMl);

  List<SleepLogModel> _recentSleepLogs = [];
  List<SleepLogModel> get recentSleepLogs => _recentSleepLogs;

  List<MealLogModel> _todayMeals = [];
  List<MealLogModel> get todayMeals => _todayMeals;
  double get todayCaloriesConsumed => _todayMeals.fold(0, (s, m) => s + m.calories);

  int _todaySteps = 0;
  int get todaySteps => _todaySteps;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Settings
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  String _language = 'English';
  String get language => _language;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  // Streak
  int get currentStreak => AchievementService.computeStreak(
      _activities.map((a) => a.date).toList());

  // Today's burned calories
  int get todayCaloriesBurned {
    final today = DateTime.now();
    return _activities
        .where((a) => a.date.year == today.year && a.date.month == today.month && a.date.day == today.day)
        .fold(0, (s, a) => s + a.caloriesBurned);
  }

  // Today's active minutes
  int get todayActiveMinutes {
    final today = DateTime.now();
    return _activities
        .where((a) => a.date.year == today.year && a.date.month == today.month && a.date.day == today.day)
        .fold(0, (s, a) => s + a.durationMinutes);
  }

  AppProvider() {
    // Defer DB init until after the first frame so the sqflite
    // plugin channel is fully registered on Android.
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await NotificationService.initialize();
    await _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.getLoggedInUser();
      if (_currentUser != null) {
        await _loadAllData();
      }
    } catch (_) {
      // DB not yet ready or session read failed — treat as logged out
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      loadActivities(),
      loadAchievements(),
      loadTodayWater(),
      loadRecentSleep(),
      loadTodayMeals(),
    ]);
  }

  // ─── AUTH ────────────────────────────────────

  Future<String?> login() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.signInWithGoogle();
      if (_currentUser != null) {
        await _loadAllData();
        _setLoading(false);
        return null;
      }
      _setLoading(false);
      return 'Sign-in cancelled';
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.loginLocal(email, password);
      if (_currentUser != null) {
        await _loadAllData();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> registerWithEmail(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _authService.registerLocal(name, email, password);
      _setLoading(false);
      return null;
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _activities = [];
    _achievements = [];
    _todayWaterLogs = [];
    _recentSleepLogs = [];
    _todayMeals = [];
    _todaySteps = 0;
    notifyListeners();
  }

  // ─── PROFILE ─────────────────────────────────

  Future<void> updateProfileImage(String photoUrl) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(photoUrl: photoUrl);
    await DatabaseHelper.instance.saveUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? name, String? age, String? mobileNumber,
    String? height, String? weight,
    int? dailyStepGoal, int? dailyCalorieGoal,
    int? dailyWaterGoalMl, int? dailyActiveMinGoal,
  }) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      name: name, age: age, mobileNumber: mobileNumber,
      height: height, weight: weight,
      dailyStepGoal: dailyStepGoal,
      dailyCalorieGoal: dailyCalorieGoal,
      dailyWaterGoalMl: dailyWaterGoalMl,
      dailyActiveMinGoal: dailyActiveMinGoal,
    );
    await DatabaseHelper.instance.saveUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  // ─── ACTIVITIES ──────────────────────────────

  Future<void> loadActivities() async {
    if (_currentUser == null) return;
    _activities = await DatabaseHelper.instance.getActivities(_currentUser!.id);
    notifyListeners();
  }

  Future<void> addActivity(ActivityModel activity) async {
    await DatabaseHelper.instance.insertActivity(activity);
    await loadActivities();
    await _checkGoalsAndAchievements();
  }

  Future<void> updateActivity(ActivityModel activity) async {
    await DatabaseHelper.instance.updateActivity(activity);
    await loadActivities();
  }

  Future<void> deleteActivity(int id) async {
    await DatabaseHelper.instance.deleteActivity(id);
    await loadActivities();
  }

  // ─── WATER ───────────────────────────────────

  Future<void> loadTodayWater() async {
    if (_currentUser == null) return;
    _todayWaterLogs = await DatabaseHelper.instance.getWaterLogs(
        _currentUser!.id, DateTime.now());
    notifyListeners();
  }

  Future<void> addWater(int amountMl) async {
    if (_currentUser == null) return;
    final log = WaterLogModel(
      userId: _currentUser!.id,
      amountMl: amountMl,
      loggedAt: DateTime.now(),
    );
    await DatabaseHelper.instance.insertWaterLog(log);
    await loadTodayWater();
    // Check water goal
    if (todayWaterMl >= (_currentUser?.dailyWaterGoalMl ?? 2000)) {
      await NotificationService.showGoalAchievement(
        '💧 Hydration Goal Reached!',
        'You\'ve hit your daily water goal. Great job!',
      );
    }
  }

  Future<void> removeWaterLog(int id) async {
    await DatabaseHelper.instance.deleteWaterLog(id);
    await loadTodayWater();
  }

  // ─── SLEEP ───────────────────────────────────

  Future<void> loadRecentSleep() async {
    if (_currentUser == null) return;
    _recentSleepLogs = await DatabaseHelper.instance.getSleepLogs(_currentUser!.id);
    notifyListeners();
  }

  Future<void> addSleepLog(SleepLogModel log) async {
    await DatabaseHelper.instance.insertSleepLog(log);
    await loadRecentSleep();
  }

  Future<void> deleteSleepLog(int id) async {
    await DatabaseHelper.instance.deleteSleepLog(id);
    await loadRecentSleep();
  }

  // ─── NUTRITION ───────────────────────────────

  Future<void> loadTodayMeals() async {
    if (_currentUser == null) return;
    _todayMeals = await DatabaseHelper.instance.getMealLogs(
        _currentUser!.id, DateTime.now());
    notifyListeners();
  }

  Future<void> addMeal(MealLogModel meal) async {
    await DatabaseHelper.instance.insertMealLog(meal);
    await loadTodayMeals();
  }

  Future<void> deleteMeal(int id) async {
    await DatabaseHelper.instance.deleteMealLog(id);
    await loadTodayMeals();
  }

  // ─── STEPS ───────────────────────────────────

  void updateTodaySteps(int steps) async {
    _todaySteps = steps;
    notifyListeners();
    if (_currentUser != null) {
      final strideM = 0.762; // avg stride length in meters
      final distKm = (steps * strideM) / 1000;
      await DatabaseHelper.instance.upsertDailySteps(
          _currentUser!.id, steps, distKm);
      if (steps >= (_currentUser?.dailyStepGoal ?? 10000) && steps - 50 < (_currentUser?.dailyStepGoal ?? 10000)) {
        await NotificationService.showGoalAchievement(
          '👟 Step Goal Reached!',
          'You\'ve walked ${steps.toStringAsFixed(0)} steps today!',
        );
      }
    }
  }

  // ─── ACHIEVEMENTS ────────────────────────────

  Future<void> loadAchievements() async {
    if (_currentUser == null) return;
    _achievements = await DatabaseHelper.instance.getAchievements(_currentUser!.id);
    notifyListeners();
  }

  Future<void> _checkGoalsAndAchievements() async {
    if (_currentUser == null) return;
    final totalCals = _activities.fold(0, (s, a) => s + a.caloriesBurned);
    final totalSteps = _activities.fold(0, (s, a) => s + a.steps);
    await AchievementService.checkAndAward(
      _currentUser!.id,
      totalActivities: _activities.length,
      totalCalories: totalCals,
      currentStreak: currentStreak,
      totalSteps: totalSteps,
      totalWorkouts: _activities.where((a) => a.type == 'Weightlifting').length,
    );
    await loadAchievements();
    // Check calorie burn goal
    if (todayCaloriesBurned >= (_currentUser?.dailyCalorieGoal ?? 2000)) {
      await NotificationService.showGoalAchievement(
        '🔥 Calorie Goal Reached!',
        'You\'ve burned your daily calorie target. Amazing!',
      );
    }
  }

  // ─── NOTIFICATIONS ───────────────────────────

  Future<void> enableWorkoutReminder(int hour, int minute) async {
    await NotificationService.scheduleWorkoutReminder(hour, minute);
  }

  Future<void> enableWaterReminders() async {
    await NotificationService.scheduleWaterReminders();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
