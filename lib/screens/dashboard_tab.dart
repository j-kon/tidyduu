import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/dashboard_provider.dart';
import 'settings_screen.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to TidyDuu',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Productivity Insights',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: -0.05, end: 0),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Completion Progress Ring Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Completion Rate',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          stats.totalTasks == 0
                              ? 'Get started by creating some tasks!'
                              : stats.completionPercentage == 1.0
                              ? 'Outstanding! You\'ve completed everything!'
                              : 'Keep pushing! You\'re getting closer.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: stats.completionPercentage,
                          strokeWidth: 10.0,
                          backgroundColor: theme.colorScheme.surface
                              .withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Text(
                        '${(stats.completionPercentage * 100).toInt()}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24.0),

            // Stats grid layout
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                      context,
                      title: 'Total Tasks',
                      value: stats.totalTasks,
                      icon: Icons.playlist_add_check_rounded,
                      color: theme.colorScheme.primary,
                    )
                    .animate(delay: 50.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                _buildStatCard(
                      context,
                      title: 'Completed',
                      value: stats.completedTasks,
                      icon: Icons.check_circle_outline_rounded,
                      color: Colors.green,
                    )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                _buildStatCard(
                      context,
                      title: 'Active',
                      value: stats.activeTasks,
                      icon: Icons.pending_actions_rounded,
                      color: Colors.orange,
                    )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                _buildStatCard(
                      context,
                      title: 'Overdue',
                      value: stats.overdueTasks,
                      icon: Icons.error_outline_rounded,
                      color: theme.colorScheme.error,
                      highlight: stats.overdueTasks > 0,
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                _buildStatCard(
                      context,
                      title: 'Due Today',
                      value: stats.todayTasks,
                      icon: Icons.today_rounded,
                      color: theme.colorScheme.secondary,
                    )
                    .animate(delay: 250.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                _buildStatCard(
                      context,
                      title: 'High Priority',
                      value: stats.highPriorityTasks,
                      icon: Icons.priority_high_rounded,
                      color: Colors.redAccent,
                    )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
              ],
            ),
            const SizedBox(height: 24.0),

            // Streaks Panel
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orange,
                          size: 28.0,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Productivity Streak',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              stats.currentStreak == 0
                                  ? 'Complete tasks daily to start a streak!'
                                  : 'You have a ${stats.currentStreak}-day streak active!',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: stats.currentStreak.toDouble(),
                        ),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, child) {
                          return Text(
                            '${val.toInt()}d',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
                .animate(delay: 300.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: highlight
              ? theme.colorScheme.error.withOpacity(0.5)
              : theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: highlight ? 1.5 : 1.0,
        ),
      ),
      color: highlight
          ? theme.colorScheme.errorContainer.withOpacity(0.1)
          : theme.colorScheme.surfaceVariant.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22.0),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Text(
                  val.toInt().toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: highlight
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
