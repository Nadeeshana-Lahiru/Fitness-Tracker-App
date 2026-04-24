import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: (user != null && user.photoUrl != null)
                            ? (kIsWeb || user.photoUrl!.startsWith('http') || user.photoUrl!.startsWith('blob')
                                ? NetworkImage(user.photoUrl!)
                                : FileImage(File(user.photoUrl!)) as ImageProvider)
                            : null,
                        backgroundColor: Colors.white,
                        child: user?.photoUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Morning',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            user?.name ?? 'Johnson Kallis',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.bell),
                      color: AppTheme.textPrimary,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Calories Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE2EAF8), Color(0xFFC7D9F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  // Mockup shows an image of a person exercising here. 
                  // In a real app we'd use decoration image, using solid gradient for now
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.flame, color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Calories',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '567 Kcal',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Increase 3%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor,
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: IconButton(
                          icon: const Icon(LucideIcons.arrowUpRight, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Select Exercise Type
              Text(
                'Select Exercise Type',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ExerciseTypeIcon(icon: LucideIcons.timer, isSelected: false),
                    _ExerciseTypeIcon(icon: LucideIcons.fileSpreadsheet, isSelected: false),
                    _ExerciseTypeIcon(icon: LucideIcons.heartPulse, isSelected: false),
                    _ExerciseTypeIcon(icon: LucideIcons.dumbbell, isSelected: false),
                    _ExerciseTypeIcon(icon: LucideIcons.scale, isSelected: false),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Total Sleep Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Sleep', style: Theme.of(context).textTheme.bodyMedium),
                            Text(
                              '7h 30min',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                          ),
                          child: const Icon(LucideIcons.arrowUpRight, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 120,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 10,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: const FlTitlesData(show: false),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _buildSleepBar(0, 4, false),
                            _buildSleepBar(1, 6, false),
                            _buildSleepBar(2, 5, false),
                            _buildSleepBar(3, 8, true),
                            _buildSleepBar(4, 5, false),
                            _buildSleepBar(5, 7, false),
                            _buildSleepBar(6, 4, false),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildSleepBar(int x, double y, bool isSelected) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2EAF8),
          width: 20,
          borderRadius: BorderRadius.circular(10),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.grey.withOpacity(0.05),
          ),
        ),
      ],
      showingTooltipIndicators: isSelected ? [0] : [],
    );
  }
}

class _ExerciseTypeIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _ExerciseTypeIcon({
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor : Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppTheme.softShadow,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : AppTheme.primaryColor,
        size: 24,
      ),
    );
  }
}

