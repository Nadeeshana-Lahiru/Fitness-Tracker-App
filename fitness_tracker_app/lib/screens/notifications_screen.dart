import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _workoutReminder = false;
  bool _waterReminder = false;
  bool _goalAlerts = true;
  bool _streakAlerts = true;
  TimeOfDay _workoutTime = const TimeOfDay(hour: 7, minute: 0);

  final List<_NotifItem> _recentNotifications = [
    _NotifItem(
      icon: LucideIcons.flame,
      color: Color(0xFFFF8A65),
      title: 'Calorie Goal Reached! 🔥',
      body: 'You\'ve burned your daily calorie target. Amazing!',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    _NotifItem(
      icon: LucideIcons.droplets,
      color: Color(0xFF4FC3F7),
      title: 'Stay Hydrated 💧',
      body: 'Don\'t forget to drink water. You\'re at 60% of your goal.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    _NotifItem(
      icon: LucideIcons.dumbbell,
      color: Color(0xFF9575CD),
      title: 'Workout Reminder 💪',
      body: 'Time for your scheduled workout! Stay consistent.',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    _NotifItem(
      icon: LucideIcons.star,
      color: Color(0xFFFFD54F),
      title: 'New Achievement Unlocked! 🏆',
      body: 'You\'ve logged 10 workouts. Keep going!',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    _NotifItem(
      icon: LucideIcons.moon,
      color: Color(0xFF7986CB),
      title: 'Sleep Reminder 😴',
      body: 'It\'s getting late. Aim for 7–9 hours of sleep tonight.',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
    ),
    _NotifItem(
      icon: LucideIcons.trophy,
      color: Color(0xFF4CAF50),
      title: '7-Day Streak! 🎉',
      body: 'You\'ve been active for 7 days in a row. Incredible!',
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  Future<void> _pickWorkoutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _workoutTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _workoutTime = picked);
      if (_workoutReminder) {
        await Provider.of<AppProvider>(context, listen: false)
            .enableWorkoutReminder(_workoutTime.hour, _workoutTime.minute);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Workout reminder set for ${_workoutTime.format(context)}'),
            backgroundColor: AppTheme.primaryColor,
          ));
        }
      }
    }
  }

  Future<void> _toggleWorkoutReminder(bool val) async {
    setState(() => _workoutReminder = val);
    if (val) {
      await Provider.of<AppProvider>(context, listen: false)
          .enableWorkoutReminder(_workoutTime.hour, _workoutTime.minute);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Workout reminder set for ${_workoutTime.format(context)}'),
          backgroundColor: AppTheme.primaryColor,
        ));
      }
    } else {
      await NotificationService.cancelAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout reminder disabled')));
      }
    }
  }

  Future<void> _toggleWaterReminder(bool val) async {
    setState(() => _waterReminder = val);
    if (val) {
      await Provider.of<AppProvider>(context, listen: false).enableWaterReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Water reminders enabled every 2 hours'),
            backgroundColor: Color(0xFF4FC3F7),
          ));
      }
    }
  }

  void _markAllRead() {
    setState(() {
      for (final n in _recentNotifications) {
        n.isRead = true;
      }
    });
  }

  int get _unreadCount => _recentNotifications.where((n) => !n.isRead).length;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(children: [
              IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Notifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  if (_unreadCount > 0)
                    Text('$_unreadCount unread',
                        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
              if (_unreadCount > 0)
                TextButton(
                  onPressed: _markAllRead,
                  child: const Text('Mark all read',
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
                ),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ── Reminder Settings ──────────────────
                Text('Reminder Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                _buildSettingCard(
                  icon: LucideIcons.dumbbell,
                  color: const Color(0xFF9575CD),
                  title: 'Workout Reminder',
                  subtitle: _workoutReminder
                      ? 'Daily at ${_workoutTime.format(context)}'
                      : 'Get reminded to work out daily',
                  value: _workoutReminder,
                  onChanged: _toggleWorkoutReminder,
                  trailing: _workoutReminder
                      ? GestureDetector(
                          onTap: _pickWorkoutTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9575CD).withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_workoutTime.format(context),
                                style: const TextStyle(
                                    color: Color(0xFF9575CD), fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 10),

                _buildSettingCard(
                  icon: LucideIcons.droplets,
                  color: const Color(0xFF4FC3F7),
                  title: 'Water Reminders',
                  subtitle: _waterReminder
                      ? 'Every 2 hours, 8 AM – 10 PM'
                      : 'Stay hydrated with hourly reminders',
                  value: _waterReminder,
                  onChanged: _toggleWaterReminder,
                ),
                const SizedBox(height: 10),

                _buildSettingCard(
                  icon: LucideIcons.flame,
                  color: const Color(0xFFFF8A65),
                  title: 'Goal Alerts',
                  subtitle: 'Notify when you reach daily goals',
                  value: _goalAlerts,
                  onChanged: (v) => setState(() => _goalAlerts = v),
                ),
                const SizedBox(height: 10),

                _buildSettingCard(
                  icon: LucideIcons.zap,
                  color: const Color(0xFFFFD54F),
                  title: 'Streak Alerts',
                  subtitle: 'Celebrate your consistency streaks',
                  value: _streakAlerts,
                  onChanged: (v) => setState(() => _streakAlerts = v),
                ),

                const SizedBox(height: 28),

                // ── Recent Notifications ───────────────
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Recent',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  if (_recentNotifications.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _recentNotifications.clear()),
                      child: const Text('Clear all',
                          style: TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                ]),
                const SizedBox(height: 12),

                if (_recentNotifications.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.softShadow),
                    child: Center(child: Column(children: [
                      Icon(LucideIcons.bellOff, size: 40, color: Colors.grey.withAlpha(120)),
                      const SizedBox(height: 12),
                      const Text('No notifications', style: TextStyle(color: AppTheme.textSecondary)),
                    ])),
                  )
                else
                  ..._recentNotifications.map((n) => _buildNotifTile(n)),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        if (trailing != null) ...[trailing, const SizedBox(width: 8)],
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryColor,
        ),
      ]),
    );
  }

  Widget _buildNotifTile(_NotifItem n) {
    return GestureDetector(
      onTap: () => setState(() => n.isRead = true),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : AppTheme.primaryColor.withAlpha(10),
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.softShadow,
          border: n.isRead ? null : Border.all(color: AppTheme.primaryColor.withAlpha(40)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: n.color.withAlpha(30), shape: BoxShape.circle),
            child: Icon(n.icon, color: n.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(n.title,
                  style: TextStyle(fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 13))),
              if (!n.isRead)
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 3),
            Text(n.body, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(_timeAgo(n.time),
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ])),
        ]),
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;
  _NotifItem({
    required this.icon, required this.color, required this.title,
    required this.body, required this.time, required this.isRead,
  });
}
