import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';

class AppProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  List<ActivityModel> _activities = [];
  List<ActivityModel> get activities => _activities;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AppProvider() {
    _initializeThemeBasedOnTime();
    _checkLoginStatus();
  }

  void _initializeThemeBasedOnTime() {
    final hour = DateTime.now().hour;
    // 6 AM to 6 PM is light mode, otherwise dark mode
    if (hour >= 6 && hour < 18) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> _checkLoginStatus() async {
    _setLoading(true);
    _currentUser = await _authService.getLoggedInUser();
    if (_currentUser != null) {
      await loadActivities();
    }
    _setLoading(false);
  }

  Future<String?> login() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.signInWithGoogle();
      if (_currentUser != null) {
        await loadActivities();
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
    _currentUser = await _authService.loginLocal(email, password);
    if (_currentUser != null) {
      await loadActivities();
      _setLoading(false);
      return true;
    }
    _setLoading(false);
    return false;
  }

  Future<String?> registerWithEmail(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _authService.registerLocal(name, email, password);
      _setLoading(false);
      return null;
    } catch (e) {
      _setLoading(false);
      return e.toString(); // Return actual error
    }
  }
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _activities = [];
    notifyListeners();
  }

  Future<void> loadActivities() async {
    if (_currentUser != null) {
      _activities = await DatabaseHelper.instance.getActivities(_currentUser!.id);
      notifyListeners();
    }
  }

  Future<void> addActivity(ActivityModel activity) async {
    await DatabaseHelper.instance.insertActivity(activity);
    await loadActivities();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
