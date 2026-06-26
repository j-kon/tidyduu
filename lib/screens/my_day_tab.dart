import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item_tile.dart';
import '../widgets/add_existing_task_bottom_sheet.dart';
import '../widgets/confetti_widget.dart';

class MyDayTab extends ConsumerWidget {
  const MyDayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final myDayTodos = ref.watch(myDayTodoListProvider);
    final stats = ref.watch(myDayStatsProvider);
    final progressMsg = ref.watch(myDayProgressMessageProvider);
    final showCelebration = ref.watch(showCelebrationProvider);

    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final formattedDate =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    // If celebration finishes, turn it off after 3 seconds
    if (showCelebration) {
      Future.delayed(const Duration(seconds: 3), () {
        ref.read(showCelebrationProvider.notifier).state = false;
      });
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // My Day Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
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
                            formattedDate,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'My Day',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.playlist_add_rounded, size: 28.0),
                        color: theme.colorScheme.primary,
                        tooltip: 'Add existing task',
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddExistingTaskBottomSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // Progress Card
                  Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.primaryContainer.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Day Progress',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              '${stats.completedCount}/${stats.totalCount} completed',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: LinearProgressIndicator(
                            value: stats.completionPercentage,
                            minHeight: 8.0,
                            backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          progressMsg,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),
            ),

            // Tasks List
            Expanded(
              child: myDayTodos.isEmpty
                  ? _buildMyDayEmptyState(context)
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 96.0),
                      itemCount: myDayTodos.length,
                      itemBuilder: (context, index) {
                        final todo = myDayTodos[index];
                        return TodoItemTile(key: ValueKey(todo.id), todo: todo);
                      },
                      onReorder: (oldIndex, newIndex) {
                        HapticFeedback.lightImpact();
                        ref
                            .read(todoListProvider.notifier)
                            .reorderMyDay(
                              myDayTodos,
                              oldIndex,
                              newIndex,
                            );
                      },
                    ),
            ),
          ],
        ),
        if (showCelebration)
          const ConfettiWidget(),
      ],
    );
  }

  Widget _buildMyDayEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wb_sunny_rounded,
                size: 64.0,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Plan your day',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Add a few tasks you want to focus on today.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddExistingTaskBottomSheet(),
                );
              },
              icon: const Icon(Icons.playlist_add_rounded),
              label: const Text('Add existing task'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
