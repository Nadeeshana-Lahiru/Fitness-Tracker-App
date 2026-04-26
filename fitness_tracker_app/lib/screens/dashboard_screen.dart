import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  void _initPedometer() {
    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen((event) {
        if (mounted) {
          Provider.of<AppProvider>(context, listen: false)
              .updateTodaySteps(event.steps);
        }
      });
    } catch (_) {
      // Pedometer not available (emulator / no permission)
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AppProvider>(context);
    final user = p.currentUser;

    final greeting = _greeting();
    final todayCals = p.todayCaloriesBurned;
    final goalCals = user?.dailyCalorieGoal ?? 2000;
    final todaySteps = p.todaySteps;
    final goalSteps = user?.dailyStepGoal ?? 10000;
    final todayWater = p.todayWaterMl;
    final goalWater = user?.dailyWaterGoalMl ?? 2000;
    final todayMins = p.todayActiveMinutes;
    final goalMins = user?.dailyActiveMinGoal ?? 30;

    ImageProvider? avatar;
    final photoUrl = user?.photoUrl;
    if (photoUrl != null) {
      avatar = (kIsWeb || photoUrl.startsWith('http') || photoUrl.startsWith('blob'))
          ? NetworkImage(photoUrl) as ImageProvider
          : FileImage(File(photoUrl));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await p.loadActivities();
            await p.loadTodayWater();
            await p.loadTodayMeals();
            await p.loadRecentSleep();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).cardColor,
                          backgroundImage: avatar,
                          child: avatar == null
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(greeting, style: Theme.of(context).textTheme.bodyMedium),
                        Text(user?.name ?? 'FitTracker',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ]),
                    ]),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Colors.grey.withAlpha(30)),
                          ),
                          child: IconButton(
                            icon: const Icon(LucideIcons.bell),
                            color: AppTheme.textPrimary,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                          ),
                        ),
                        Positioned(
                          right: 8, top: 8,
                          child: Container(
                            width: 9, height: 9,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5252), shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Streak Banner ───────────────────────
                if (p.currentStreak > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      const Text('🔥', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${p.currentStreak}-Day Streak!',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('Keep it up — you\'re on a roll!',
                            style: TextStyle(
                                color: Colors.white.withAlpha(220), fontSize: 12)),
                      ]),
                    ]),
                  ),

                // ── Activity Rings ──────────────────────
                Text('Today\'s Goals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: _GoalCard(
                      label: 'Calories',
                      value: todayCals,
                      goal: goalCals,
                      unit: 'kcal',
                      icon: LucideIcons.flame,
                      color: const Color(0xFFFF8A65),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GoalCard(
                      label: 'Steps',
                      value: todaySteps,
                      goal: goalSteps,
                      unit: 'steps',
                      icon: LucideIcons.footprints,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _GoalCard(
                      label: 'Water',
                      value: todayWater,
                      goal: goalWater,
                      unit: 'ml',
                      icon: LucideIcons.droplets,
                      color: const Color(0xFF4FC3F7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GoalCard(
                      label: 'Active',
                      value: todayMins,
                      goal: goalMins,
                      unit: 'mins',
                      icon: LucideIcons.timer,
                      color: const Color(0xFF7FE0C7),
                    ),
                  ),
                ]),

                const SizedBox(height: 28),

                // ── Quick Add Water ─────────────────────
                Text('Quick Add Water',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 14),
                Row(children: [
                  for (final ml in [150, 250, 350, 500])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => p.addWater(ml),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: Theme.of(context).brightness == Brightness.light ? AppTheme.softShadow : null,
                          ),
                          child: Column(children: [
                            const Icon(LucideIcons.glassWater,
                                color: Color(0xFF4FC3F7), size: 20),
                            const SizedBox(height: 6),
                            Text('${ml}ml',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 11)),
                          ]),
                        ),
                      ),
                    ),
                ]),

                const SizedBox(height: 28),

                // ── Exercise Types ──────────────────────
                Text('Exercise Type',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ExerciseChip(icon: LucideIcons.timer, label: 'Cardio'),
                      _ExerciseChip(icon: LucideIcons.dumbbell, label: 'Strength'),
                      _ExerciseChip(icon: LucideIcons.heartPulse, label: 'Yoga'),
                      _ExerciseChip(icon: LucideIcons.bike, label: 'Cycling'),
                      _ExerciseChip(icon: LucideIcons.waves, label: 'Swim'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Sleep Card ──────────────────────────
                Text('Sleep',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 14),
                _buildSleepCard(context, p),

                const SizedBox(height: 28),

                // ── Recent Activity ─────────────────────
                if (p.activities.isNotEmpty) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                    Text('${p.activities.length} total',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
                  const SizedBox(height: 14),
                  _buildWeeklyChart(context, p.activities),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  Widget _buildSleepCard(BuildContext context, AppProvider p) {
    final sleep = p.recentSleepLogs.isNotEmpty ? p.recentSleepLogs.first : null;
    final hours = sleep?.hoursSlept ?? 0;
    final h = hours.floor();
    final m = ((hours - h) * 60).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: Theme.of(context).brightness == Brightness.light ? AppTheme.softShadow : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Sleep', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              sleep == null ? 'No data' : '${h}h ${m}min',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
          ]),
          if (sleep != null)
            Row(children: List.generate(5, (i) => Icon(
              LucideIcons.star,
              size: 16,
              color: i < sleep.qualityRating ? Colors.amber : Colors.grey.withAlpha(80),
            ))),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 12,
            barTouchData: BarTouchData(enabled: false),
            titlesData: const FlTitlesData(show: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: _buildSleepBars(p.recentSleepLogs),
          )),
        ),
      ]),
    );
  }

  List<BarChartGroupData> _buildSleepBars(List sleepLogs) {
    return List.generate(7, (i) {
      final idx = sleepLogs.length > (6 - i) ? 6 - i : -1;
      final hours = idx >= 0 ? sleepLogs[idx].hoursSlept : 0.0;
      final isToday = i == 6;
      return BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(
          toY: hours.clamp(0, 12),
          color: isToday ? AppTheme.primaryColor : const Color(0xFFE2EAF8),
          width: 18,
          borderRadius: BorderRadius.circular(8),
        )],
      );
    });
  }

  Widget _buildWeeklyChart(BuildContext context, List activities) {
    final now = DateTime.now();
    final barGroups = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final cals = activities
          .where((a) => a.date.year == day.year && a.date.month == day.month && a.date.day == day.day)
          .fold<int>(0, (s, a) => s + (a.caloriesBurned as int));
      return BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(
          toY: cals.toDouble(),
          color: AppTheme.primaryColor.withAlpha(180 + (i * 11).clamp(0, 75)),
          width: 22,
          borderRadius: BorderRadius.circular(10),
        )],
      );
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: Theme.of(context).brightness == Brightness.light ? AppTheme.softShadow : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('7-Day Calorie Burn',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        SizedBox(
          height: 140,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 3000,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    final day = now.subtract(Duration(days: 6 - v.toInt()));
                    return Text(
                      days[day.weekday - 1],
                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
          )),
        ),
      ]),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String label;
  final int value;
  final int goal;
  final String unit;
  final IconData icon;
  final Color color;

  const _GoalCard({
    required this.label, required this.value, required this.goal,
    required this.unit, required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: Theme.of(context).brightness == Brightness.light ? AppTheme.softShadow : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        Text('$value',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, fontSize: 20)),
        Text(unit, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withAlpha(40),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).toInt()}% of $goal $unit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
      ]),
    );
  }
}

class _ExerciseChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ExerciseChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Theme.of(context).brightness == Brightness.light ? AppTheme.softShadow : null,
      ),
      child: Column(children: [
        Icon(icon, color: AppTheme.primaryColor, size: 22),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary)),
      ]),
    );
  }
}
