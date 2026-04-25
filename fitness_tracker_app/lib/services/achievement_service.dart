import '../models/health_models.dart';
import 'database_helper.dart';
import 'notification_service.dart';

class AchievementService {
  static Future<void> checkAndAward(String userId, {
    required int totalActivities,
    required int totalCalories,
    required int currentStreak,
    required int totalSteps,
    required int totalWorkouts,
  }) async {
    final badges = <_Badge>[
      _Badge('first_workout', '🎯 First Step!', 'Logged your very first activity!', '🎯',
          totalActivities >= 1),
      _Badge('workouts_5', '⭐ Getting Active', 'Completed 5 activities!', '⭐',
          totalActivities >= 5),
      _Badge('workouts_10', '🔥 On Fire', 'Completed 10 activities!', '🔥',
          totalActivities >= 10),
      _Badge('workouts_25', '💪 Dedicated', 'Completed 25 activities!', '💪',
          totalActivities >= 25),
      _Badge('workouts_50', '🏋️ Fitness Warrior', 'Completed 50 activities!', '🏋️',
          totalActivities >= 50),
      _Badge('streak_3', '🔆 3-Day Streak', 'Active 3 days in a row!', '🔆',
          currentStreak >= 3),
      _Badge('streak_7', '🗓️ Week Warrior', 'Active 7 days in a row!', '🗓️',
          currentStreak >= 7),
      _Badge('streak_30', '📅 Monthly Master', 'Active 30 days in a row!', '📅',
          currentStreak >= 30),
      _Badge('calories_1k', '🌟 1K Burned', 'Burned 1,000 total calories!', '🌟',
          totalCalories >= 1000),
      _Badge('calories_10k', '⚡ 10K Milestone', 'Burned 10,000 total calories!', '⚡',
          totalCalories >= 10000),
      _Badge('steps_10k', '👟 First 10K Steps', 'Walked 10,000 steps in a day!', '👟',
          totalSteps >= 10000),
      _Badge('steps_100k', '🚶 Step Legend', 'Reached 100,000 lifetime steps!', '🚶',
          totalSteps >= 100000),
    ];

    for (final badge in badges) {
      if (!badge.condition) continue;
      final already = await DatabaseHelper.instance.hasBadge(userId, badge.key);
      if (already) continue;

      final achievement = AchievementModel(
        userId: userId,
        badgeKey: badge.key,
        title: badge.title,
        description: badge.description,
        iconEmoji: badge.emoji,
        earnedAt: DateTime.now(),
      );
      await DatabaseHelper.instance.insertAchievement(achievement);
      await NotificationService.showAchievementEarned(badge.title, badge.description);
    }
  }

  static int computeStreak(List<DateTime> activityDates) {
    if (activityDates.isEmpty) return 0;
    final sorted = activityDates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime expected = DateTime.now();
    expected = DateTime(expected.year, expected.month, expected.day);

    for (final day in sorted) {
      if (day == expected || day == expected.subtract(const Duration(days: 1))) {
        streak++;
        expected = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}

class _Badge {
  final String key;
  final String title;
  final String description;
  final String emoji;
  final bool condition;
  const _Badge(this.key, this.title, this.description, this.emoji, this.condition);
}
