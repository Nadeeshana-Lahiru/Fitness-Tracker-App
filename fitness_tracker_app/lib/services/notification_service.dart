import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _goalsDetails = NotificationDetails(
    android: AndroidNotificationDetails('goals_channel', 'Goal Achievements',
        channelDescription: 'Notifications when you reach your fitness goals',
        importance: Importance.high, priority: Priority.high),
    iOS: DarwinNotificationDetails(),
  );

  static const _achievementDetails = NotificationDetails(
    android: AndroidNotificationDetails('achievements_channel', 'Achievements',
        channelDescription: 'Achievement badge notifications',
        importance: Importance.high, priority: Priority.high),
    iOS: DarwinNotificationDetails(),
  );

  static const _workoutDetails = NotificationDetails(
    android: AndroidNotificationDetails('workout_reminder', 'Workout Reminders',
        channelDescription: 'Daily workout reminder notifications',
        importance: Importance.high, priority: Priority.high),
    iOS: DarwinNotificationDetails(),
  );

  static const _waterDetails = NotificationDetails(
    android: AndroidNotificationDetails('water_reminder', 'Water Reminders',
        channelDescription: 'Periodic water intake reminders',
        importance: Importance.defaultImportance, priority: Priority.defaultPriority),
    iOS: DarwinNotificationDetails(),
  );

  static const _summaryDetails = NotificationDetails(
    android: AndroidNotificationDetails('weekly_summary', 'Weekly Summaries',
        channelDescription: 'Weekly fitness summary notifications',
        importance: Importance.defaultImportance, priority: Priority.defaultPriority),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (_) {},
    );
    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showGoalAchievement(String title, String body) async {
    await _plugin.show(
      id: 100, title: title, body: body,
      notificationDetails: _goalsDetails,
    );
  }

  static Future<void> showAchievementEarned(String title, String body) async {
    await _plugin.show(
      id: 200, title: '🏆 $title', body: body,
      notificationDetails: _achievementDetails,
    );
  }

  static Future<void> scheduleWorkoutReminder(int hour, int minute) async {
    await _plugin.cancel(id: 1);
    await _plugin.zonedSchedule(
      id: 1,
      title: '💪 Time to Work Out!',
      body: 'Your daily fitness goal is waiting. Let\'s go!',
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: _workoutDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleWaterReminders() async {
    for (int i = 0; i < 8; i++) {
      final hour = 8 + (i * 2);
      await _plugin.zonedSchedule(
        id: 300 + i,
        title: '💧 Stay Hydrated!',
        body: 'Time to drink a glass of water.',
        scheduledDate: _nextInstanceOfTime(hour, 0),
        notificationDetails: _waterDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> scheduleWeeklySummary(int weeklyCalories, int workouts) async {
    await _plugin.show(
      id: 400,
      title: '📊 Your Weekly Summary',
      body: 'You burned $weeklyCalories kcal in $workouts workouts this week. Keep it up!',
      notificationDetails: _summaryDetails,
    );
  }

  static Future<void> cancelAll() async => _plugin.cancelAll();

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
