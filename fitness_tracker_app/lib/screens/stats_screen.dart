import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AppProvider>(context);
    final acts = p.activities;

    final now = DateTime.now();
    final todayMeals = p.todayMeals;
    final consumed = p.todayCaloriesConsumed;
    final burned = p.todayCaloriesBurned;
    final netCals = consumed - burned;

    // Weekly bar data
    final weekData = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayActs = acts.where((a) =>
          a.date.year == day.year && a.date.month == day.month && a.date.day == day.day);
      return dayActs.fold(0, (s, a) => s + a.caloriesBurned).toDouble();
    });
    final maxY = weekData.isEmpty ? 500.0 : (weekData.reduce((a, b) => a > b ? a : b) + 200).clamp(500, 5000).toDouble();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Calorie Stats',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                      border: Border.all(color: Colors.grey.withAlpha(40))),
                  child: IconButton(
                    icon: const Icon(LucideIcons.calendar),
                    color: AppTheme.textPrimary, onPressed: () {},
                  ),
                ),
              ]),
              const SizedBox(height: 28),

              // Weekly Chart Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: AppTheme.softShadow),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Analytics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text('${weekData.fold(0.0, (a, b) => a + b).toInt()} Cals',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFFF8A65), fontWeight: FontWeight.w600)),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        const Icon(LucideIcons.flame, color: AppTheme.primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${burned} Cals', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Burned today', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        ]),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 160,
                    child: BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                              BarTooltipItem('${rod.toY.toInt()} kcal',
                                  const TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const d = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final day = now.subtract(Duration(days: 6 - v.toInt()));
                            return Text(d[day.weekday - 1],
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary));
                          },
                        )),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (i) => BarChartGroupData(
                        x: i,
                        barRods: [BarChartRodData(
                          toY: weekData[i],
                          color: AppTheme.primaryColor.withAlpha(150 + (i * 15).clamp(0, 105)),
                          width: 30,
                          borderRadius: BorderRadius.circular(12),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true, toY: maxY, color: Colors.grey.withAlpha(15)),
                        )],
                      )),
                    )),
                  ),
                ]),
              ),

              const SizedBox(height: 28),

              // Nutrition Summary
              Text('Today\'s Nutrition',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.softShadow),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _NutritionStat(label: 'Consumed', value: '${consumed.toInt()} kcal', color: Colors.orange),
                    _NutritionStat(label: 'Burned', value: '$burned kcal', color: AppTheme.primaryColor),
                    _NutritionStat(label: 'Net', value: '${netCals.toInt()} kcal',
                        color: netCals > 0 ? Colors.red : Colors.green),
                  ]),
                  const SizedBox(height: 16),
                  // Macro breakdown
                  if (todayMeals.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _MacroChip(label: 'Protein', g: todayMeals.fold(0.0, (s, m) => s + m.protein), color: Colors.blue),
                      _MacroChip(label: 'Carbs', g: todayMeals.fold(0.0, (s, m) => s + m.carbs), color: Colors.orange),
                      _MacroChip(label: 'Fat', g: todayMeals.fold(0.0, (s, m) => s + m.fat), color: Colors.red),
                    ]),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () => context.push('/log-meal'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(LucideIcons.plus, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('Log a Meal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    ),
                ]),
              ),

              const SizedBox(height: 28),

              // Today's Meals
              if (todayMeals.isNotEmpty) ...[
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Today\'s Meals',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                  GestureDetector(
                    onTap: () => context.push('/log-meal'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(20)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(LucideIcons.plus, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Add', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                ...todayMeals.map((m) => _MealTile(meal: m, onDelete: () => Provider.of<AppProvider>(context, listen: false).deleteMeal(m.id!))),
              ],

              const SizedBox(height: 28),

              // Challenges
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Challenges',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                Text('Active', style: Theme.of(context).textTheme.bodyMedium),
              ]),
              const SizedBox(height: 14),
              ..._buildChallenges(context, p),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChallenges(BuildContext context, AppProvider p) {
    final acts = p.activities;
    final weekCals = acts.where((a) {
      final wAgo = DateTime.now().subtract(const Duration(days: 7));
      return a.date.isAfter(wAgo);
    }).fold(0, (s, a) => s + a.caloriesBurned);

    final challenges = [
      {'name': 'Burn 3,500 kcal this week', 'icon': '🔥', 'current': weekCals, 'goal': 3500, 'completed': weekCals >= 3500},
      {'name': 'Log 5 workouts this week', 'icon': '💪', 'current': acts.length.clamp(0, 5), 'goal': 5, 'completed': acts.length >= 5},
      {'name': 'Stay hydrated — 2L water', 'icon': '💧', 'current': p.todayWaterMl, 'goal': 2000, 'completed': p.todayWaterMl >= 2000},
    ];

    return challenges.map((c) {
      final progress = ((c['current'] as int) / (c['goal'] as int)).clamp(0.0, 1.0);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.backgroundColor, shape: BoxShape.circle),
              child: Text(c['icon'] as String, style: const TextStyle(fontSize: 22))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.primaryColor.withAlpha(30),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              c['completed'] as bool ? 'Completed! 🎉' : '${(progress * 100).toInt()}% complete',
              style: TextStyle(
                fontSize: 11,
                color: c['completed'] as bool ? Colors.green : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ])),
        ]),
      );
    }).toList();
  }
}

class _NutritionStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _NutritionStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    ]);
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double g;
  final Color color;
  const _MacroChip({required this.label, required this.g, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('${g.toStringAsFixed(1)}g', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
    ]);
  }
}

class _MealTile extends StatelessWidget {
  final dynamic meal;
  final VoidCallback onDelete;
  const _MealTile({required this.meal, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppTheme.softShadow),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(12)),
          child: Text(_mealEmoji(meal.mealType), style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(meal.mealType[0].toUpperCase() + meal.mealType.substring(1),
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${meal.calories.toInt()} kcal',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)),
          Text('${meal.servingGrams.toInt()}g',
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ]),
        IconButton(
          icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
          onPressed: onDelete,
        ),
      ]),
    );
  }

  String _mealEmoji(String type) {
    switch (type) {
      case 'breakfast': return '🌅';
      case 'lunch': return '🍱';
      case 'dinner': return '🍽️';
      default: return '🍎';
    }
  }
}
