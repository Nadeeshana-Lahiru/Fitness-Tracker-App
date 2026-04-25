import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _workoutReminders = false;
  bool _waterReminders = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked != null) setState(() => _reminderTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AppProvider>(context);
    final user = p.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: () => context.pop()),
        title: Text('Settings', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Goals Section
          _SectionHeader('Daily Goals'),
          _GoalTile(
            label: 'Step Goal',
            icon: LucideIcons.footprints,
            value: '${user?.dailyStepGoal ?? 10000}',
            unit: 'steps',
            onTap: () => _editGoal(context, p, 'steps', user?.dailyStepGoal ?? 10000),
          ),
          _GoalTile(
            label: 'Calorie Burn Goal',
            icon: LucideIcons.flame,
            value: '${user?.dailyCalorieGoal ?? 2000}',
            unit: 'kcal',
            onTap: () => _editGoal(context, p, 'calories', user?.dailyCalorieGoal ?? 2000),
          ),
          _GoalTile(
            label: 'Water Goal',
            icon: LucideIcons.droplets,
            value: '${user?.dailyWaterGoalMl ?? 2000}',
            unit: 'ml',
            onTap: () => _editGoal(context, p, 'water', user?.dailyWaterGoalMl ?? 2000),
          ),
          _GoalTile(
            label: 'Active Minutes Goal',
            icon: LucideIcons.timer,
            value: '${user?.dailyActiveMinGoal ?? 30}',
            unit: 'mins',
            onTap: () => _editGoal(context, p, 'minutes', user?.dailyActiveMinGoal ?? 30),
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _SectionHeader('Notifications'),
          _SettingsTile(
            icon: LucideIcons.dumbbell,
            title: 'Workout Reminder',
            subtitle: 'Daily reminder at ${_reminderTime.format(context)}',
            trailing: Switch(
              value: _workoutReminders,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (v) async {
                setState(() => _workoutReminders = v);
                if (v) {
                  await p.enableWorkoutReminder(_reminderTime.hour, _reminderTime.minute);
                } else {
                  await NotificationService.cancelAll();
                }
              },
            ),
          ),
          if (_workoutReminders)
            _SettingsTile(
              icon: LucideIcons.clock,
              title: 'Reminder Time',
              subtitle: _reminderTime.format(context),
              trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
              onTap: _pickReminderTime,
            ),
          _SettingsTile(
            icon: LucideIcons.glassWater,
            title: 'Water Reminders',
            subtitle: 'Reminders every 2 hours',
            trailing: Switch(
              value: _waterReminders,
              activeThumbColor: AppTheme.primaryColor,
              onChanged: (v) async {
                setState(() => _waterReminders = v);
                if (v) await p.enableWaterReminders();
              },
            ),
          ),

          const SizedBox(height: 24),

          // Data Section
          _SectionHeader('Data & Privacy'),
          _SettingsTile(
            icon: LucideIcons.moon,
            title: 'Sleep History',
            subtitle: 'View all sleep logs',
            trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
            onTap: () => context.push('/sleep-log'),
          ),
          _SettingsTile(
            icon: LucideIcons.scale,
            title: 'Body Metrics',
            subtitle: 'Weight, BMI, body fat history',
            trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // About Section
          _SectionHeader('About'),
          _SettingsTile(
            icon: LucideIcons.info,
            title: 'App Version',
            subtitle: '1.0.0 — FitTrack',
            trailing: const SizedBox.shrink(),
          ),
          _SettingsTile(
            icon: LucideIcons.shield,
            title: 'Privacy Policy',
            trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _SectionHeader('Account'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppTheme.softShadow),
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withAlpha(20), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.logOut, color: Colors.red, size: 20)),
              title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await p.logout();
                  if (mounted) context.go('/login');
                }
              },
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _editGoal(BuildContext context, AppProvider p, String type, int current) {
    final ctrl = TextEditingController(text: '$current');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withAlpha(80), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Edit ${type[0].toUpperCase()}${type.substring(1)} Goal',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl, keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () async {
                final val = int.tryParse(ctrl.text) ?? current;
                await p.updateUserProfile(
                  dailyStepGoal: type == 'steps' ? val : null,
                  dailyCalorieGoal: type == 'calories' ? val : null,
                  dailyWaterGoalMl: type == 'water' ? val : null,
                  dailyActiveMinGoal: type == 'minutes' ? val : null,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: const Text('Save'),
            )),
          ]),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppTheme.softShadow),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFD3E0FA), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryColor, size: 18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)) : null,
        trailing: trailing,
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final VoidCallback onTap;
  const _GoalTile({required this.label, required this.icon, required this.value, required this.unit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppTheme.softShadow),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFD3E0FA), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryColor, size: 18)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('Current: $value $unit', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFD3E0FA), borderRadius: BorderRadius.circular(20)),
          child: const Text('Edit', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
        ),
      ),
    );
  }
}
