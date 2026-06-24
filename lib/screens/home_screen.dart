import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/add_edit_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/todo_item_tile.dart';

import '../models/todo.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref; // so we don't have to change other WidgetRef references, wait! In ConsumerState.build, the ref field is directly available, but let's double check. Yes, ref is a field of ConsumerState.
    final theme = Theme.of(context);
    final filteredTodos = ref.watch(filteredTodoListProvider);
    final activeFilter = ref.watch(todoFilterProvider);
    final stats = ref.watch(todoStatsProvider);

    // Format current date manually to keep dependencies light
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final formattedDate = '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
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
                                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
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
                          stats.totalCount == 0
                              ? 'No tasks for today. Add one below!'
                              : stats.completionPercentage == 1.0
                                  ? 'Amazing! You\'ve completed everything!'
                                  : 'Keep going, you\'re doing great!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
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
                onChanged: (value) => ref.read(todoSearchQueryProvider.notifier).state = value,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 20.0),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
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
                    _CategoryFilterChip(
                      label: 'All Categories',
                      icon: Icons.grid_view_rounded,
                      isSelected: ref.watch(todoCategoryFilterProvider) == null,
                      onTap: () => ref.read(todoCategoryFilterProvider.notifier).state = null,
                    ),
                    ...TodoCategory.values.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _CategoryFilterChip(
                          label: _getCategoryLabel(category),
                          icon: _getCategoryIcon(category),
                          isSelected: ref.watch(todoCategoryFilterProvider) == category,
                          onTap: () => ref.read(todoCategoryFilterProvider.notifier).state = category,
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
                    _FilterChip(
                      label: 'All',
                      isSelected: activeFilter == TodoFilter.all,
                      count: stats.totalCount,
                      onTap: () => ref.read(todoFilterProvider.notifier).state = TodoFilter.all,
                    ),
                    const SizedBox(width: 8.0),
                    _FilterChip(
                      label: 'Active',
                      isSelected: activeFilter == TodoFilter.active,
                      count: stats.activeCount,
                      onTap: () => ref.read(todoFilterProvider.notifier).state = TodoFilter.active,
                    ),
                    const SizedBox(width: 8.0),
                    _FilterChip(
                      label: 'Completed',
                      isSelected: activeFilter == TodoFilter.completed,
                      count: stats.completedCount,
                      onTap: () => ref.read(todoFilterProvider.notifier).state = TodoFilter.completed,
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
                        return TodoItemTile(
                          key: ValueKey(todo.id),
                          todo: todo,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddEditDialog(),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _getCategoryLabel(TodoCategory cat) {
    switch (cat) {
      case TodoCategory.personal:
        return 'Personal';
      case TodoCategory.work:
        return 'Work';
      case TodoCategory.study:
        return 'Study';
      case TodoCategory.errands:
        return 'Errands';
      case TodoCategory.other:
        return 'Other';
    }
  }

  IconData _getCategoryIcon(TodoCategory cat) {
    switch (cat) {
      case TodoCategory.personal:
        return Icons.person_rounded;
      case TodoCategory.work:
        return Icons.work_rounded;
      case TodoCategory.study:
        return Icons.menu_book_rounded;
      case TodoCategory.errands:
        return Icons.shopping_bag_rounded;
      case TodoCategory.other:
        return Icons.category_rounded;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.onPrimary.withOpacity(0.2)
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.0,
              color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
