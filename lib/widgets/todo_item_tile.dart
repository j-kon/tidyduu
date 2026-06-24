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
              // Task Title and Description
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
                    if (todo.description.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
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
                onPressed: () {
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
