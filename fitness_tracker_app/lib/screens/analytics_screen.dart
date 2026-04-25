import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AppProvider>(context);
    final user = p.currentUser;
    final acts = p.activities;

    final totalCals = acts.fold(0, (s, a) => s + a.caloriesBurned);
    final totalMins = acts.fold(0, (s, a) => s + a.durationMinutes);
    final totalSteps = acts.fold(0, (s, a) => s + a.steps);
    final streak = p.currentStreak;

    // This month stats
    final now = DateTime.now();
    final monthActs = acts.where((a) => a.date.year == now.year && a.date.month == now.month).toList();
    final monthCals = monthActs.fold(0, (s, a) => s + a.caloriesBurned);
    final monthMins = monthActs.fold(0, (s, a) => s + a.durationMinutes);

    // Step goal completion
    final goalSteps = user?.dailyStepGoal ?? 10000;
    final todaySteps = p.todaySteps;
    final stepPercent = (todaySteps / goalSteps * 100).clamp(0, 100).toInt();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Analytics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withAlpha(40)),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.share2),
                      color: AppTheme.textPrimary,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Today Steps Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3E0FA),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text('Walking', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 16),
                      Text('$stepPercent%',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48)),
                      Text('Today\'s step goal', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary.withAlpha(150))),
                    ]),
                    SizedBox(
                      width: 100, height: 100,
                      child: Stack(alignment: Alignment.center, children: [
                        CircularProgressIndicator(
                          value: stepPercent / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.white.withAlpha(120),
                          valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                        ),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('$todaySteps',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('steps', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        ]),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Streak + Motivation Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: streak >= 3
                      ? const Color(0xFFFFF9C4)
                      : const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      streak >= 7 ? LucideIcons.crown : LucideIcons.flame,
                      color: streak >= 3 ? Colors.amber : AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      streak >= 7 ? 'Bravo! You Crushed It!' : streak >= 3 ? 'On a Roll!' : 'Start Your Streak!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      streak >= 3
                          ? 'You\'ve been active $streak days in a row. Keep going!'
                          : 'Log an activity every day to build your streak.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5, color: AppTheme.textPrimary.withAlpha(160)),
                    ),
                  ])),
                ]),
              ),
              const SizedBox(height: 16),

              // Stats Grid
              Row(children: [
                Expanded(child: _StatTile(
                  title: '${monthCals.toStringAsFixed(0)} kcal',
                  subtitle: 'This month burned',
                  icon: LucideIcons.flame,
                  color: const Color(0xFFFFE0B2),
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(
                  title: '${monthMins} mins',
                  subtitle: 'Active this month',
                  icon: LucideIcons.clock,
                  color: const Color(0xFFFFF9C4),
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatTile(
                  title: '$totalSteps',
                  subtitle: 'Total steps',
                  icon: LucideIcons.footprints,
                  color: const Color(0xFFD3E0FA),
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(
                  title: '${acts.length}',
                  subtitle: 'Total workouts',
                  icon: LucideIcons.dumbbell,
                  color: const Color(0xFFE8F5E9),
                )),
              ]),
              const SizedBox(height: 16),

              // All-time totals card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDE0FE),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('$totalCals',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40)),
                      Text('Total calories burned (all time)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary.withAlpha(170))),
                    ]),
                    SizedBox(
                      width: 60, height: 60,
                      child: Stack(alignment: Alignment.center, children: [
                        CircularProgressIndicator(
                          value: (totalMins / 60 / 100).clamp(0, 1),
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withAlpha(120),
                          valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                        ),
                        Icon(LucideIcons.activity, color: AppTheme.primaryColor, size: 22),
                      ]),
                    ),
                  ],
                ),
              ),

              // Achievements
              if (p.achievements.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Achievements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                  Text('${p.achievements.length} earned',
                      style: Theme.of(context).textTheme.bodyMedium),
                ]),
                const SizedBox(height: 14),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: p.achievements.length,
                    itemBuilder: (ctx, i) {
                      final a = p.achievements[i];
                      return Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Column(children: [
                          Text(a.iconEmoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text(a.title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ]),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  const _StatTile({required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black87, size: 18)),
        const SizedBox(height: 14),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textPrimary.withAlpha(150))),
      ]),
    );
  }
}
