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
              // Task Title, Date and Description
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
                    const SizedBox(height: 2.0),
                    // Formatted Timestamp
                    Row(
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
                    if (todo.description.isNotEmpty) ...[
                      const SizedBox(height: 6.0),
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
                  // Show premium Material 3 confirmation dialog
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
