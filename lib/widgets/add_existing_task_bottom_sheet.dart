import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class AddExistingTaskBottomSheet extends ConsumerStatefulWidget {
  const AddExistingTaskBottomSheet({super.key});

  @override
  ConsumerState<AddExistingTaskBottomSheet> createState() =>
      _AddExistingTaskBottomSheetState();
}

class _AddExistingTaskBottomSheetState
    extends ConsumerState<AddExistingTaskBottomSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todos = ref.watch(todoListProvider);

    // Filter tasks: active, not in My Day
    final myDayIds = ref.watch(myDayTodoListProvider).map((t) => t.id).toSet();

    List<Todo> availableTasks = todos.where((todo) {
      final isNotInMyDay = !myDayIds.contains(todo.id);
      final matchesSearch =
          todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          todo.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return isNotInMyDay && matchesSearch;
    }).toList();

    // Sort: active tasks first, then priority, then due date
    availableTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28.0),
        topRight: Radius.circular(28.0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.75),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28.0),
              topRight: Radius.circular(28.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Task to My Day',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search active tasks...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 16.0),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: availableTasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No tasks available to add.'
                                : 'No tasks match "$_searchQuery"',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableTasks.length,
                        itemBuilder: (context, index) {
                          final todo = availableTasks[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: todo.priority.containerColor(
                                context,
                              ),
                              foregroundColor: todo.priority.onContainerColor(
                                context,
                              ),
                              child: Icon(todo.category.icon, size: 18.0),
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isCompleted
                                    ? theme.colorScheme.onSurface.withOpacity(
                                        0.5,
                                      )
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              todo.description.isNotEmpty
                                  ? todo.description
                                  : todo.category.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                              ),
                              color: theme.colorScheme.primary,
                              onPressed: () {
                                ref
                                    .read(todoListProvider.notifier)
                                    .addToMyDay(todo.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added "${todo.title}" to My Day',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
