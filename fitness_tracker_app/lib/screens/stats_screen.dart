import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calorie Stats',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.calendar),
                      color: AppTheme.textPrimary,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Analytics Chart Card
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
                            Text(
                              'Analytics',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '1,200 Cals', // Using Cals instead of Calls from the mockup typo
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFFF8A65), // Soft red/orange
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.flame, color: AppTheme.primaryColor, size: 16),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '145 Cals',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Burn',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 10,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: const FlTitlesData(show: false),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _buildStatBar(0, 5, false),
                            _buildStatBar(1, 3, false),
                            _buildStatBar(2, 6, false),
                            _buildStatBar(3, 4, false),
                            _buildStatBar(4, 9, true),
                            _buildStatBar(5, 6, false),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Challenges Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Challenge',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  Text(
                    'See All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Challenge List
              _buildChallengeCard(
                context,
                title: 'Swimming in The Sea',
                subtitle: 'Completed!',
                subtitleColor: AppTheme.greenAccent,
                trailingValue: '319 cals',
                icon: LucideIcons.waves,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildChallengeCard(
                context,
                title: 'Run 4 Laps in Court',
                subtitle: 'Completed!',
                subtitleColor: AppTheme.greenAccent,
                trailingValue: '426 cals',
                icon: LucideIcons.footprints,
                iconColor: Colors.orange,
              ),

              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildStatBar(int x, double y, bool isSelected) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primaryColor.withOpacity(isSelected ? 1.0 : 0.8),
          width: 32, // Thicker bars as in mockup
          borderRadius: BorderRadius.circular(16),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.grey.withOpacity(0.05), // Very light background path
          ),
        ),
      ],
      // The mockup shows a dot indicator above the active bar.
      // We can approximate this by drawing it, or using showingTooltipIndicators.
      showingTooltipIndicators: isSelected ? [0] : [],
    );
  }

  Widget _buildChallengeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required String trailingValue,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(LucideIcons.flame, color: AppTheme.primaryColor, size: 16),
              const SizedBox(height: 4),
              Text(
                trailingValue,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
