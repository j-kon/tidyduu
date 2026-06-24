import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';

class EmptyState extends StatelessWidget {
  final TodoFilter filter;

  const EmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title;
    String subtitle;
    IconData icon;

    switch (filter) {
      case TodoFilter.active:
        title = 'All caught up!';
        subtitle = 'No active tasks remaining. Enjoy your free time!';
        icon = Icons.task_alt_rounded;
        break;
      case TodoFilter.completed:
        title = 'No completed tasks';
        subtitle = 'Tasks you finish will show up here. Keep going!';
        icon = Icons.star_border_rounded;
        break;
      case TodoFilter.all:
      default:
        title = 'Clear mind, clean slate';
        subtitle = 'Tap the button below to create your first todo task.';
        icon = Icons.checklist_rtl_rounded;
        break;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64.0, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
