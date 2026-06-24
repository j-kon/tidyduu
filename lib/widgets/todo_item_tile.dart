import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'add_edit_dialog.dart';

class TodoItemTile extends ConsumerWidget {
  final Todo todo;

  const TodoItemTile({super.key, required this.todo});

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

  Widget? _buildDueDateBadge(BuildContext context) {
    if (todo.dueDate == null) return null;
    final theme = Theme.of(context);

    // Calculate if overdue
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDue = DateTime(
      todo.dueDate!.year,
      todo.dueDate!.month,
      todo.dueDate!.day,
    );
    final isOverdue = !todo.isCompleted && taskDue.isBefore(today);

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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: isCompleted
              ? theme.colorScheme.outlineVariant.withOpacity(0.4)
              : theme.colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      color: isCompleted
          ? theme.colorScheme.surfaceVariant.withOpacity(0.2)
          : theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          ref.read(todoListProvider.notifier).toggleTodo(todo.id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Circular checkbox toggle
              Semantics(
                label: isCompleted ? 'Mark active' : 'Mark completed',
                value: isCompleted ? 'checked' : 'unchecked',
                child: GestureDetector(
                  onTap: () {
                    ref.read(todoListProvider.notifier).toggleTodo(todo.id);
                  },
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
                            : theme.colorScheme.onSurfaceVariant.withOpacity(
                                0.8,
                              ),
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
                          _buildDueDateBadge(context)!,
                          if (todo.reminder != TodoReminder.none) ...[
                            _buildReminderBadge(context)!,
                          ],
                        ],
                      ],
                    ),
                    if (todo.description.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Text(
                        todo.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isCompleted
                              ? theme.colorScheme.onSurfaceVariant.withOpacity(
                                  0.4,
                                )
                              : theme.colorScheme.onSurfaceVariant,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              // Action Buttons
              IconButton(
                icon: Icon(
                  todo.isToday
                      ? Icons.wb_sunny_rounded
                      : Icons.wb_sunny_outlined,
                  size: 20.0,
                ),
                color: todo.isToday
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                tooltip: todo.isToday ? 'Remove from Today' : 'Add to Today',
                onPressed: () {
                  ref.read(todoListProvider.notifier).toggleToday(todo.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20.0),
                color: theme.colorScheme.onSurfaceVariant,
                tooltip: 'Edit task',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddEditDialog(todo: todo),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20.0),
                color: theme.colorScheme.error.withOpacity(0.8),
                tooltip: 'Delete task',
                onPressed: () async {
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

                  if (confirmDelete == true && context.mounted) {
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
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
