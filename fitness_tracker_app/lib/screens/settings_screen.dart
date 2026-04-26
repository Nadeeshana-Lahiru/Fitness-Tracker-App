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
  String _selectedLanguage = 'English (US)';

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked != null) setState(() => _reminderTime = picked);
  }

  void _showLanguagePicker(AppProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(p.tr('Select Language'), style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...['English', 'Sinhala', 'Tamil'].map(
              (lang) => ListTile(
                title: Text(lang, style: TextStyle(fontWeight: lang == p.language ? FontWeight.bold : FontWeight.normal)),
                trailing: lang == p.language ? const Icon(LucideIcons.check, color: AppTheme.primaryColor) : null,
                onTap: () {
                  p.setLanguage(lang);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(AppProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(p.tr('Select Theme'), style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _themeOption(ctx, p, 'Light', ThemeMode.light, LucideIcons.sun),
            _themeOption(ctx, p, 'Dark', ThemeMode.dark, LucideIcons.moon),
            _themeOption(ctx, p, 'System Default', ThemeMode.system, LucideIcons.laptop),
          ],
        ),
      ),
    );
  }

  void _showUnitsPicker(AppProvider p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(p.tr('Select Units'), style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...['Metric (kg, cm, ml)', 'Imperial (lb, in, oz)'].map(
              (unit) => ListTile(
                title: Text(unit, style: TextStyle(fontWeight: (unit.contains(p.units)) ? FontWeight.bold : FontWeight.normal)),
                trailing: (unit.contains(p.units)) ? const Icon(LucideIcons.check, color: AppTheme.primaryColor) : null,
                onTap: () {
                  p.setUnits(unit.contains('Metric') ? 'Metric' : 'Imperial');
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBodyMetricsPicker(AppProvider p) {
    final weightCtrl = TextEditingController(text: p.currentUser?.weight ?? '');
    final heightCtrl = TextEditingController(text: p.currentUser?.height ?? '');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(p.tr('Body Metrics'), style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Weight (${p.units == 'Metric' ? 'kg' : 'lb'})', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Height (${p.units == 'Metric' ? 'cm' : 'in'})', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await p.updateUserProfile(weight: weightCtrl.text, height: heightCtrl.text);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(p.tr('Save')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(BuildContext context, AppProvider p, String label, ThemeMode mode, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(p.tr(label), style: TextStyle(fontWeight: p.themeMode == mode ? FontWeight.bold : FontWeight.normal)),
      trailing: p.themeMode == mode ? const Icon(LucideIcons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        p.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'At FitTrack, we take your privacy seriously. Your health data is stored locally on your device and is not shared with any third parties without your explicit consent. \n\n'
            '1. Data Collection: We collect activities, heart rate, and sleep data to provide insights.\n'
            '2. Data Security: All data is encrypted and stored securely.\n'
            '3. User Control: You can delete your data at any time from the settings.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AppProvider>(context);
    final user = p.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // No back button as requested
        title: Text(p.tr('Settings'), style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24), // Added top padding (40)
        children: [
          // Goals Section
          _SectionHeader(p.tr('Daily Goals')),
          _GoalTile(
            label: p.tr('Step Goal'),
            icon: LucideIcons.footprints,
            value: '${user?.dailyStepGoal ?? 10000}',
            unit: 'steps',
            onTap: () => _editGoal(context, p, 'steps', user?.dailyStepGoal ?? 10000),
          ),
          _GoalTile(
            label: p.tr('Calorie Burn Goal'),
            icon: LucideIcons.flame,
            value: '${user?.dailyCalorieGoal ?? 2000}',
            unit: 'kcal',
            onTap: () => _editGoal(context, p, 'calories', user?.dailyCalorieGoal ?? 2000),
          ),
          _GoalTile(
            label: p.tr('Water Goal'),
            icon: LucideIcons.droplets,
            value: '${user?.dailyWaterGoalMl ?? 2000}',
            unit: 'ml',
            onTap: () => _editGoal(context, p, 'water', user?.dailyWaterGoalMl ?? 2000),
          ),
          _GoalTile(
            label: p.tr('Active Minutes Goal'),
            icon: LucideIcons.timer,
            value: '${user?.dailyActiveMinGoal ?? 30}',
            unit: 'mins',
            onTap: () => _editGoal(context, p, 'minutes', user?.dailyActiveMinGoal ?? 30),
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _SectionHeader(p.tr('Notifications')),
          _SettingsTile(
            icon: LucideIcons.dumbbell,
            title: p.tr('Workout Reminder'),
            subtitle: 'Daily reminder at ${_reminderTime.format(context)}',
            trailing: Switch(
              value: _workoutReminders,
              activeColor: AppTheme.primaryColor,
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
            title: p.tr('Water Reminders'),
            subtitle: 'Reminders every 2 hours',
            trailing: Switch(
              value: _waterReminders,
              activeColor: AppTheme.primaryColor,
              onChanged: (v) async {
                setState(() => _waterReminders = v);
                if (v) await p.enableWaterReminders();
              },
            ),
          ),

          const SizedBox(height: 24),

          // Data Section
          _SectionHeader(p.tr('Data & Privacy')),
          _SettingsTile(
            icon: LucideIcons.moon,
            title: 'Sleep History',
            subtitle: 'View all sleep logs',
            trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
            onTap: () => context.push('/sleep-log'),
          ),
          _SettingsTile(
            icon: LucideIcons.scale,
            title: p.tr('Body Metrics'),
            subtitle: 'Weight, BMI, body fat history',
            trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
            onTap: () => _showBodyMetricsPicker(p),
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _SectionHeader(p.tr('Preferences')),
          _SettingsTile(
            icon: LucideIcons.globe,
            title: p.tr('Language'),
            subtitle: p.language,
            trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
            onTap: () => _showLanguagePicker(p),
          ),
          _SettingsTile(
            icon: LucideIcons.moon,
            title: p.tr('Theme'),
            subtitle: p.themeMode == ThemeMode.system ? p.tr('System Default') : (p.themeMode == ThemeMode.light ? p.tr('Light') : p.tr('Dark')),
            trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
            onTap: () => _showThemePicker(p),
          ),
          _SettingsTile(
            icon: LucideIcons.ruler,
            title: p.tr('Units'),
            subtitle: p.units == 'Metric' ? 'Metric (kg, cm, ml)' : 'Imperial (lb, in, oz)',
            trailing: const Icon(LucideIcons.chevronRight, size: 18, color: AppTheme.textSecondary),
            onTap: () => _showUnitsPicker(p),
          ),

          const SizedBox(height: 24),

          // About Section
          _SectionHeader(p.tr('About')),
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
            onTap: _showPrivacyPolicy,
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _SectionHeader('Account'),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: Theme.of(context).brightness == Brightness.light ? AppTheme.softShadow : AppTheme.darkSoftShadow,
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withAlpha(20), shape: BoxShape.circle),
                child: const Icon(LucideIcons.logOut, color: Colors.red, size: 20),
              ),
              title: Text(p.tr('Logout'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Text(p.tr('Logout')),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(ctx, true), child: Text(p.tr('Logout'))),
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: Theme.of(context).brightness == Brightness.light ? AppTheme.softShadow : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: Theme.of(context).brightness == Brightness.light ? AppTheme.softShadow : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 18),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('Current: $value $unit', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Edit', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
        ),
      ),
    );
  }
}
