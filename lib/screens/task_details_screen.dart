import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/add_edit_dialog.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final String todoId;

  const TaskDetailsScreen({super.key, required this.todoId});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  final TextEditingController _subtaskController = TextEditingController();
  final FocusNode _subtaskFocusNode = FocusNode();

  @override
  void dispose() {
    _subtaskController.dispose();
    _subtaskFocusNode.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
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
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute $period';
  }

  void _addSubtask(BuildContext context) {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      ref.read(todoListProvider.notifier).addSubtask(widget.todoId, text);
      _subtaskController.clear();
      _subtaskFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todos = ref.watch(todoListProvider);

    // Find the current todo, handle case where it might be deleted while viewing
    final todoIndex = todos.indexWhere((t) => t.id == widget.todoId);
    if (todoIndex == -1) {
      // Todo was deleted, go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final todo = todos[todoIndex];
    final isCompleted = todo.isCompleted;

    // Calculate subtask stats
    final totalSubtasks = todo.subtasks.length;
    final completedSubtasks = todo.subtasks.where((s) => s.isCompleted).length;
    final progress = totalSubtasks == 0
        ? 0.0
        : completedSubtasks / totalSubtasks;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Task',
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
            icon: Icon(
              todo.isPlannedForToday
                  ? Icons.wb_sunny_rounded
                  : Icons.wb_sunny_outlined,
              color: todo.isPlannedForToday ? theme.colorScheme.primary : null,
            ),
            tooltip: todo.isPlannedForToday
                ? 'Remove from My Day'
                : 'Add to My Day',
            onPressed: () {
              ref.read(todoListProvider.notifier).toggleMyDay(todo.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Category & Priority Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                todo.category.icon,
                                size: 14.0,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                todo.category.label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: todo.priority.containerColor(context),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            '${todo.priority.label} Priority',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: todo.priority.onContainerColor(context),
                            ),
                          ),
                        ),
                        if (todo.repeatOption != TodoRepeat.none) ...[
                          const SizedBox(width: 10.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer
                                  .withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sync,
                                  size: 14.0,
                                  color: theme.colorScheme.tertiary,
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  todo.repeatOption.label,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20.0),

                    // Task Title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isCompleted,
                          activeColor: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          onChanged: (_) {
                            ref
                                .read(todoListProvider.notifier)
                                .toggleTodo(todo.id);
                          },
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todo.title,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? theme.colorScheme.onSurface.withOpacity(
                                          0.5,
                                        )
                                      : theme.colorScheme.onSurface,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              if (todo.description.isNotEmpty) ...[
                                const SizedBox(height: 8.0),
                                Text(
                                  todo.description,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Due Date & Reminder Section
                    if (todo.dueDate != null) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 18.0,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Due Date',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (todo.reminder != TodoReminder.none) ...[
                              const SizedBox(width: 16.0),
                              Icon(
                                Icons.notifications_active_rounded,
                                size: 18.0,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reminder',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    todo.reminder.label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Divider(),
                    ],

                    // Notes Section
                    if (todo.notes.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      Text(
                        'Notes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.2,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withOpacity(
                              0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          todo.notes,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                    ],

                    // Subtasks checklist section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtasks',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (totalSubtasks > 0)
                          Text(
                            '$completedSubtasks/$totalSubtasks completed',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12.0),

                    if (totalSubtasks > 0) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6.0,
                          backgroundColor: theme.colorScheme.surfaceVariant
                              .withOpacity(0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 16.0),
                    ],

                    // Subtasks builder list
                    if (totalSubtasks == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No subtasks created for this task yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalSubtasks,
                        itemBuilder: (context, index) {
                          final subtask = todo.subtasks[index];
                          return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                color: subtask.isCompleted
                                    ? theme.colorScheme.surfaceVariant
                                          .withOpacity(0.1)
                                    : theme.colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(
                                    color: theme.colorScheme.outlineVariant
                                        .withOpacity(0.5),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  leading: Checkbox(
                                    value: subtask.isCompleted,
                                    activeColor: theme.colorScheme.primary,
                                    onChanged: (_) {
                                      ref
                                          .read(todoListProvider.notifier)
                                          .toggleSubtask(todo.id, subtask.id);
                                    },
                                  ),
                                  title: TextFormField(
                                    initialValue: subtask.title,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      decoration: subtask.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: subtask.isCompleted
                                          ? theme.colorScheme.onSurface
                                                .withOpacity(0.5)
                                          : theme.colorScheme.onSurface,
                                    ),
                                    onFieldSubmitted: (newTitle) {
                                      if (newTitle.trim().isNotEmpty) {
                                        ref
                                            .read(todoListProvider.notifier)
                                            .editSubtask(
                                              todo.id,
                                              subtask.id,
                                              newTitle.trim(),
                                            );
                                      }
                                    },
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18.0,
                                    ),
                                    color: theme.colorScheme.error.withOpacity(
                                      0.7,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(todoListProvider.notifier)
                                          .deleteSubtask(todo.id, subtask.id);
                                    },
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 200.ms)
                              .slideX(begin: 0.05, end: 0);
                        },
                      ),

                    const SizedBox(height: 24.0),
                    const Divider(),
                    const SizedBox(height: 8.0),

                    // Task Creation/Update Dates
                    Text(
                      'Created: ${_formatDateTime(todo.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Updated: ${_formatDateTime(todo.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ),

            // Subtask Add Input Panel
            Container(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 12.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.6),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      focusNode: _subtaskFocusNode,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Add subtask...',
                        isDense: true,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(
                          0.3,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _addSubtask(context),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () => _addSubtask(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
