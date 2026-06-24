import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chips.dart';
import '../widgets/todo_item_tile.dart';

class TasksTab extends ConsumerStatefulWidget {
  const TasksTab({super.key});

  @override
  ConsumerState<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends ConsumerState<TasksTab> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(todoSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTodos = ref.watch(filteredTodoListProvider);
    final activeFilter = ref.watch(todoFilterProvider);
    final stats = ref.watch(todoStatsProvider);

    // Format current date manually to keep dependencies light
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
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
      'December',
    ];
    final formattedDate =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
          child: Column(
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
                'TidyDuu',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: -0.5,
                ),
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
                          'Task Progress',
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
                        backgroundColor: theme.colorScheme.surface.withOpacity(
                          0.3,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      stats.totalCount == 0
                          ? 'No tasks for today. Add one below!'
                          : stats.completionPercentage == 1.0
                          ? 'Amazing! You\'ve completed everything!'
                          : 'Keep going, you\'re doing great!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(
                          0.8,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search Bar Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                ref.read(todoSearchQueryProvider.notifier).state = value,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
                size: 20.0,
              ),
              suffixIcon: ref.watch(todoSearchQueryProvider).isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20.0),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(todoSearchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 16.0,
              ),
            ),
          ),
        ),

        // Category Chips Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CategoryFilterChipWidget(
                  label: 'All Categories',
                  icon: Icons.grid_view_rounded,
                  isSelected: ref.watch(todoCategoryFilterProvider) == null,
                  onTap: () =>
                      ref.read(todoCategoryFilterProvider.notifier).state =
                          null,
                ),
                ...TodoCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CategoryFilterChipWidget(
                      label: category.label,
                      icon: category.icon,
                      isSelected:
                          ref.watch(todoCategoryFilterProvider) == category,
                      onTap: () =>
                          ref.read(todoCategoryFilterProvider.notifier).state =
                              category,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        // Filter Chips Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChipWidget(
                  label: 'All',
                  isSelected: activeFilter == TodoFilter.all,
                  count: stats.totalCount,
                  onTap: () => ref.read(todoFilterProvider.notifier).state =
                      TodoFilter.all,
                ),
                const SizedBox(width: 8.0),
                FilterChipWidget(
                  label: 'Active',
                  isSelected: activeFilter == TodoFilter.active,
                  count: stats.activeCount,
                  onTap: () => ref.read(todoFilterProvider.notifier).state =
                      TodoFilter.active,
                ),
                const SizedBox(width: 8.0),
                FilterChipWidget(
                  label: 'Completed',
                  isSelected: activeFilter == TodoFilter.completed,
                  count: stats.completedCount,
                  onTap: () => ref.read(todoFilterProvider.notifier).state =
                      TodoFilter.completed,
                ),
              ],
            ),
          ),
        ),

        // Tasks List / Empty State
        Expanded(
          child: filteredTodos.isEmpty
              ? EmptyState(filter: activeFilter)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 96.0),
                  itemCount: filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];
                    return TodoItemTile(key: ValueKey(todo.id), todo: todo);
                  },
                ),
        ),
      ],
    );
  }
}
