import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../screens/task_details_screen.dart';
import '../widgets/add_edit_dialog.dart';

class TodoItemTile extends ConsumerWidget {
  final Todo todo;

  const TodoItemTile({super.key, required this.todo});

  void _toggleCompletion(BuildContext context, WidgetRef ref) {
    final wasCompleted = todo.isCompleted;
    ref.read(todoListProvider.notifier).toggleTodo(todo.id);

    if (!wasCompleted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task completed! 🎉'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      );

      final myDayTodos = ref.read(myDayTodoListProvider);
      final activeMyDay = myDayTodos
          .where((t) => !t.isCompleted && t.id != todo.id)
          .toList();

      if (myDayTodos.isNotEmpty && activeMyDay.isEmpty) {
        ref.read(showCelebrationProvider.notifier).state = true;
      }
    } else {
      HapticFeedback.lightImpact();
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDate = DateTime(dt.year, dt.month, dt.day);

    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    if (taskDate == today) {
      return 'Today at $timeStr';
    } else if (taskDate == yesterday) {
      return 'Yesterday at $timeStr';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day} at $timeStr';
    }
  }

  Widget _buildPriorityBadge(BuildContext context) {
    final theme = Theme.of(context);
    final priority = todo.priority;

    Color bgColor = todo.isCompleted
        ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
        : priority.containerColor(context);
    Color textColor = todo.isCompleted
        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
        : priority.onContainerColor(context);

    return Semantics(
      label: 'Priority: ${priority.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          priority.label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget? _buildTodayBadge(BuildContext context) {
    if (!todo.isToday) return null;
    final theme = Theme.of(context);

    Color bgColor = theme.colorScheme.primaryContainer.withOpacity(0.3);
    Color textColor = theme.colorScheme.primary;

    if (todo.isCompleted) {
      bgColor = theme.colorScheme.surfaceVariant.withOpacity(0.5);
      textColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.4);
    }

    return Semantics(
      label: 'Starred for today',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: textColor.withOpacity(0.3), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny_rounded, size: 12.0, color: textColor),
            const SizedBox(width: 4.0),
            Text(
              'Today',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    final theme = Theme.of(context);
    final category = todo.category;

    Color bgColor = todo.isCompleted
        ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
        : theme.colorScheme.primaryContainer.withOpacity(0.8);
    Color textColor = todo.isCompleted
        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
        : theme.colorScheme.onPrimaryContainer;

    return Semantics(
      label: 'Category: ${category.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 12.0, color: textColor),
            const SizedBox(width: 4.0),
            Text(
              category.label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildDueDateBadge(BuildContext context, bool isOverdue) {
    if (todo.dueDate == null) return null;
    final theme = Theme.of(context);

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr =
        'Due: ${months[todo.dueDate!.month - 1]} ${todo.dueDate!.day}';

    Color textColor;
    IconData icon;

    if (isOverdue) {
      textColor = theme.colorScheme.error;
      icon = Icons.warning_amber_rounded;
    } else {
      textColor = todo.isCompleted
          ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
          : theme.colorScheme.onSurfaceVariant;
      icon = Icons.calendar_today_rounded;
    }

    return Semantics(
      label: isOverdue ? 'Overdue: $dateStr' : dateStr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.0, color: textColor),
          const SizedBox(width: 4.0),
          Text(
            dateStr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildReminderBadge(BuildContext context) {
    if (todo.dueDate == null || todo.reminder == TodoReminder.none) return null;
    final theme = Theme.of(context);

    final textColor = todo.isCompleted
        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label: 'Reminder: ${todo.reminder.label}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_active_rounded,
            size: 12.0,
            color: textColor,
          ),
          const SizedBox(width: 4.0),
          Text(
            todo.reminder.shortLabel,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCompleted = todo.isCompleted;

    // Check if overdue
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue =
        todo.dueDate != null &&
        !isCompleted &&
        DateTime(
          todo.dueDate!.year,
          todo.dueDate!.month,
          todo.dueDate!.day,
        ).isBefore(today);

    // Calculate subtask stats
    final totalSubtasks = todo.subtasks.length;
    final completedSubtasks = todo.subtasks.where((s) => s.isCompleted).length;
    final subtaskProgress = totalSubtasks == 0
        ? 0.0
        : completedSubtasks / totalSubtasks;

    return Dismissible(
          key: ValueKey('dismiss_${todo.id}'),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Confirm Delete Dialog
              final confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.error,
                    size: 28.0,
                  ),
                  title: const Text('Delete Task?'),
                  content: Text(
                    'Are you sure you want to delete "${todo.title}"? This cannot be undone.',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              return confirmDelete ?? false;
            } else {
              // Toggle completeness directly via swipe
              return true;
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              HapticFeedback.heavyImpact();
              final notifier = ref.read(todoListProvider.notifier);
              notifier.deleteTodo(todo.id);

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${todo.title}" deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: theme.colorScheme.primaryContainer,
                    onPressed: () {
                      notifier.restoreTodo(todo);
                    },
                  ),
                ),
              );
            } else {
              _toggleCompletion(context, ref);
            }
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            padding: const EdgeInsets.only(left: 20.0),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              children: [
                Icon(
                  isCompleted
                      ? Icons.radio_button_unchecked_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 8.0),
                Text(
                  isCompleted ? 'Mark Active' : 'Mark Completed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            padding: const EdgeInsets.only(right: 20.0),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.0),
                Icon(Icons.delete_outline_rounded, color: Colors.white),
              ],
            ),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: isOverdue
                    ? theme.colorScheme.error.withOpacity(0.6)
                    : (isCompleted
                          ? theme.colorScheme.outlineVariant.withOpacity(0.4)
                          : theme.colorScheme.outlineVariant),
                width: isOverdue ? 1.5 : 1.0,
              ),
            ),
            color: isCompleted
                ? theme.colorScheme.surfaceVariant.withOpacity(0.2)
                : theme.colorScheme.surface,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaskDetailsScreen(todoId: todo.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    // Circular checkbox toggle
                    Semantics(
                      label: isCompleted ? 'Mark active' : 'Mark completed',
                      value: isCompleted ? 'checked' : 'unchecked',
                      child: GestureDetector(
                        onTap: () => _toggleCompletion(context, ref),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24.0,
                          height: 24.0,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isCompleted
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant
                                        .withOpacity(0.8),
                              width: 2.0,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: isCompleted
                              ? const Icon(
                                      Icons.check,
                                      size: 14.0,
                                      color: Colors.white,
                                    )
                                    .animate()
                                    .scale(
                                      duration: 250.ms,
                                      curve: Curves.elasticOut,
                                    )
                                    .rotate(duration: 200.ms)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    // Task Title, Metadata wrap and Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? theme.colorScheme.onSurface.withOpacity(0.4)
                                  : theme.colorScheme.onSurface,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          // Responsive Metadata wrap
                          Wrap(
                            spacing: 12.0,
                            runSpacing: 6.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (todo.isToday) _buildTodayBadge(context)!,
                              _buildCategoryBadge(context),
                              _buildPriorityBadge(context),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12.0,
                                    color: isCompleted
                                        ? theme.colorScheme.onSurfaceVariant
                                              .withOpacity(0.3)
                                        : theme.colorScheme.onSurfaceVariant
                                              .withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    _formatDateTime(todo.createdAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isCompleted
                                          ? theme.colorScheme.onSurfaceVariant
                                                .withOpacity(0.3)
                                          : theme.colorScheme.onSurfaceVariant
                                                .withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (todo.dueDate != null) ...[
                                _buildDueDateBadge(context, isOverdue)!,
                                if (todo.reminder != TodoReminder.none) ...[
                                  _buildReminderBadge(context)!,
                                ],
                              ],
                              if (todo.notes.isNotEmpty) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.notes_rounded,
                                      size: 12.0,
                                      color: isCompleted
                                          ? theme.colorScheme.onSurfaceVariant
                                                .withOpacity(0.3)
                                          : theme.colorScheme.onSurfaceVariant
                                                .withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      'Notes',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: isCompleted
                                                ? theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withOpacity(0.3)
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withOpacity(0.6),
                                            fontSize: 10.0,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                              if (todo.repeatOption != TodoRepeat.none) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sync,
                                      size: 12.0,
                                      color: isCompleted
                                          ? theme.colorScheme.onSurfaceVariant
                                                .withOpacity(0.3)
                                          : theme.colorScheme.primary
                                                .withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      todo.repeatOption.label,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: isCompleted
                                                ? theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withOpacity(0.3)
                                                : theme.colorScheme.primary
                                                      .withOpacity(0.8),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10.0,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          if (todo.description.isNotEmpty) ...[
                            const SizedBox(height: 8.0),
                            Text(
                              todo.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isCompleted
                                    ? theme.colorScheme.onSurfaceVariant
                                          .withOpacity(0.4)
                                    : theme.colorScheme.onSurfaceVariant,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ],
                          if (totalSubtasks > 0) ...[
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: LinearProgressIndicator(
                                      value: subtaskProgress,
                                      minHeight: 4.0,
                                      backgroundColor: theme
                                          .colorScheme
                                          .surfaceVariant
                                          .withOpacity(0.5),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isCompleted
                                            ? theme.colorScheme.onSurfaceVariant
                                                  .withOpacity(0.3)
                                            : theme.colorScheme.primary
                                                  .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  '$completedSubtasks/$totalSubtasks',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isCompleted
                                        ? theme.colorScheme.onSurfaceVariant
                                              .withOpacity(0.3)
                                        : theme.colorScheme.onSurfaceVariant
                                              .withOpacity(0.8),
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.8,
                        ),
                      ),
                      tooltip: 'Task Actions',
                      onSelected: (value) async {
                        switch (value) {
                          case 'my_day':
                            ref
                                .read(todoListProvider.notifier)
                                .toggleMyDay(todo.id);
                            break;
                          case 'today':
                            ref
                                .read(todoListProvider.notifier)
                                .toggleToday(todo.id);
                            break;
                          case 'edit':
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => AddEditDialog(todo: todo),
                            );
                            break;
                          case 'delete':
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: theme.colorScheme.error,
                                  size: 28.0,
                                ),
                                title: const Text('Delete Task?'),
                                content: Text(
                                  'Are you sure you want to delete "${todo.title}"? This cannot be undone.',
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                actionsAlignment: MainAxisAlignment.spaceEvenly,
                                actions: [
                                  OutlinedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                      foregroundColor:
                                          theme.colorScheme.onError,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmDelete == true) {
                              HapticFeedback.heavyImpact();
                              final notifier = ref.read(
                                todoListProvider.notifier,
                              );
                              notifier.deleteTodo(todo.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"${todo.title}" deleted'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              );
                            }
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'my_day',
                          child: Row(
                            children: [
                              Icon(
                                todo.isPlannedForToday
                                    ? Icons.wb_sunny_rounded
                                    : Icons.wb_sunny_outlined,
                                size: 20.0,
                                color: todo.isPlannedForToday
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              const SizedBox(width: 12.0),
                              Text(
                                todo.isPlannedForToday
                                    ? 'Remove from My Day'
                                    : 'Add to My Day',
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'today',
                          child: Row(
                            children: [
                              Icon(
                                todo.isToday
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 20.0,
                                color: todo.isToday ? Colors.amber : null,
                              ),
                              const SizedBox(width: 12.0),
                              Text(todo.isToday ? 'Unstar Task' : 'Star Task'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20.0),
                              SizedBox(width: 12.0),
                              Text('Edit Task'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 20.0,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 12.0),
                              Text(
                                'Delete Task',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic)
        .animate(target: isCompleted ? 1.0 : 0.0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(0.98, 0.98),
          duration: 200.ms,
          curve: Curves.easeInOut,
        )
        .custom(
          builder: (context, value, child) =>
              Opacity(opacity: 1.0 - (value * 0.2), child: child),
        );
  }
}
