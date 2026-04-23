import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  // User Operations
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString('users') ?? '[]';
    final List<dynamic> usersJson = jsonDecode(usersString);
    
    final existingIndex = usersJson.indexWhere((u) => u['id'] == user.id);
    if (existingIndex >= 0) {
      usersJson[existingIndex] = user.toMap();
    } else {
      usersJson.add(user.toMap());
    }
    
    await prefs.setString('users', jsonEncode(usersJson));
  }

  Future<UserModel?> getUser(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString('users') ?? '[]';
    final List<dynamic> usersJson = jsonDecode(usersString);
    
    final userMap = usersJson.cast<Map<String, dynamic>>().firstWhere(
      (u) => u['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    
    if (userMap.isNotEmpty) {
      return UserModel.fromMap(userMap);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString('users') ?? '[]';
    final List<dynamic> usersJson = jsonDecode(usersString);
    
    final userMap = usersJson.cast<Map<String, dynamic>>().firstWhere(
      (u) => u['email'] == email,
      orElse: () => <String, dynamic>{},
    );
    
    if (userMap.isNotEmpty) {
      return UserModel.fromMap(userMap);
    }
    return null;
  }

  // Activity Operations
  Future<int> insertActivity(ActivityModel activity) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesString = prefs.getString('activities') ?? '[]';
    final List<dynamic> activitiesJson = jsonDecode(activitiesString);
    
    final id = activitiesJson.length + 1;
    final activityWithId = ActivityModel(
      id: id,
      userId: activity.userId,
      type: activity.type,
      durationMinutes: activity.durationMinutes,
      caloriesBurned: activity.caloriesBurned,
      steps: activity.steps,
      date: activity.date,
    );
    
    activitiesJson.add(activityWithId.toMap());
    await prefs.setString('activities', jsonEncode(activitiesJson));
    return id;
  }

  Future<List<ActivityModel>> getActivities(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesString = prefs.getString('activities') ?? '[]';
    final List<dynamic> activitiesJson = jsonDecode(activitiesString);
    
    final userActivities = activitiesJson
        .cast<Map<String, dynamic>>()
        .where((a) => a['userId'] == userId)
        .map((a) => ActivityModel.fromMap(a))
        .toList();
        
    userActivities.sort((a, b) => b.date.compareTo(a.date));
    return userActivities;
  }

  Future<int> deleteActivity(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesString = prefs.getString('activities') ?? '[]';
    final List<dynamic> activitiesJson = jsonDecode(activitiesString);
    
    activitiesJson.removeWhere((a) => a['id'] == id);
    await prefs.setString('activities', jsonEncode(activitiesJson));
    return id;
  }
}
