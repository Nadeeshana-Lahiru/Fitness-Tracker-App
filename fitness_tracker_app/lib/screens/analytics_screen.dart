import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
                    'Analytics',
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
                      icon: const Icon(LucideIcons.search),
                      color: AppTheme.textPrimary,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Walking Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3E0FA), // Soft blue background for the card
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.circle, size: 8, color: Colors.black),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Walking',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '89%',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total in this month',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    // Circular Progress
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 0.89,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '54 miles',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Walking',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bravo Motivational Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE), // Very light blue
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.crown, color: Colors.amber, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bravo! You Crushed It!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Great job! You walked 5% more than last month. Keep going!',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textPrimary.withOpacity(0.6),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Grid of Small Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSmallCard(
                      context,
                      color: const Color(0xFFFFF9C4), // Light yellow
                      icon: LucideIcons.flame,
                      title: '2559 kcal',
                      subtitle: 'Calories burned',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSmallCard(
                      context,
                      color: const Color(0xFFFFE0B2), // Light orange
                      icon: LucideIcons.clock,
                      title: '52 mins',
                      subtitle: 'Active time today',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Steps Walked Today Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDE0FE), // Light blue
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '120',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 40,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Steps walked today',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    // Partial Circular Progress for Steps
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 0.12, // 120 steps is a small percentage
                            strokeWidth: 6,
                            backgroundColor: Colors.white.withOpacity(0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          ),
                          const Icon(LucideIcons.footprints, color: AppTheme.primaryColor, size: 24),
                        ],
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

  Widget _buildSmallCard(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
