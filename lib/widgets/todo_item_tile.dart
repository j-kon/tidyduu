import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'add_edit_dialog.dart';

class TodoItemTile extends ConsumerWidget {
  final Todo todo;

  const TodoItemTile({
    super.key,
    required this.todo,
  });

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
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day} at $timeStr';
    }
  }

  Widget _buildPriorityBadge(BuildContext context) {
    final theme = Theme.of(context);
    String label;
    Color bgColor;
    Color textColor;

    switch (todo.priority) {
      case TodoPriority.high:
        label = 'High';
        bgColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        break;
      case TodoPriority.medium:
        label = 'Medium';
        bgColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        break;
      case TodoPriority.low:
      default:
        label = 'Low';
        bgColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        break;
    }

    if (todo.isCompleted) {
      bgColor = theme.colorScheme.surfaceVariant.withOpacity(0.5);
      textColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    final theme = Theme.of(context);
    String label;
    IconData icon;
    Color bgColor;
    Color textColor;

    switch (todo.category) {
      case TodoCategory.personal:
        label = 'Personal';
        icon = Icons.person_rounded;
        bgColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        break;
      case TodoCategory.work:
        label = 'Work';
        icon = Icons.work_rounded;
        bgColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        break;
      case TodoCategory.study:
        label = 'Study';
        icon = Icons.menu_book_rounded;
        bgColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        break;
      case TodoCategory.errands:
        label = 'Errands';
        icon = Icons.shopping_bag_rounded;
        bgColor = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
        break;
      case TodoCategory.other:
      default:
        label = 'Other';
        icon = Icons.category_rounded;
        bgColor = theme.colorScheme.surfaceVariant;
        textColor = theme.colorScheme.onSurfaceVariant;
        break;
    }

    if (todo.isCompleted) {
      bgColor = theme.colorScheme.surfaceVariant.withOpacity(0.5);
      textColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.0,
            color: textColor,
          ),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildDueDateBadge(BuildContext context) {
    if (todo.dueDate == null) return null;
    final theme = Theme.of(context);

    // Calculate if overdue
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDue = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
    final isOverdue = !todo.isCompleted && taskDue.isBefore(today);

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = 'Due: ${months[todo.dueDate!.month - 1]} ${todo.dueDate!.day}';

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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12.0,
          color: textColor,
        ),
        const SizedBox(width: 4.0),
        Text(
          dateStr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
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
              GestureDetector(
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
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
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
                        _buildCategoryBadge(context),
                        _buildPriorityBadge(context),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12.0,
                              color: isCompleted
                                  ? theme.colorScheme.onSurfaceVariant.withOpacity(0.3)
                                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              _formatDateTime(todo.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isCompleted
                                    ? theme.colorScheme.onSurfaceVariant.withOpacity(0.3)
                                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (todo.dueDate != null) ...[
                          _buildDueDateBadge(context)!,
                        ],
                      ],
                    ),
                    if (todo.description.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Text(
                        todo.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isCompleted
                              ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
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
                      content: Text('Are you sure you want to delete "${todo.title}"? This cannot be undone.'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
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
