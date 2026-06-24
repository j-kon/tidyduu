import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class AddEditDialog extends ConsumerStatefulWidget {
  final Todo? todo;

  const AddEditDialog({super.key, this.todo});

  @override
  ConsumerState<AddEditDialog> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends ConsumerState<AddEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TodoPriority _selectedPriority;
  DateTime? _selectedDueDate;
  late TodoCategory _selectedCategory;
  late bool _selectedIsToday;
  late TodoReminder _selectedReminder;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );
    _selectedPriority = widget.todo?.priority ?? TodoPriority.medium;
    _selectedCategory = widget.todo?.category ?? TodoCategory.other;
    _selectedReminder = widget.todo?.reminder ?? TodoReminder.none;

    if (widget.todo == null) {
      final activeTab = ref.read(appTabProvider);
      if (activeTab == AppTab.today) {
        final now = DateTime.now();
        _selectedDueDate = DateTime(now.year, now.month, now.day);
        _selectedIsToday = true;
      } else if (activeTab == AppTab.calendar) {
        _selectedDueDate = ref.read(calendarSelectedDateProvider);
        _selectedIsToday = false;
      } else {
        _selectedDueDate = null;
        _selectedIsToday = false;
      }
    } else {
      _selectedDueDate = widget.todo!.dueDate;
      _selectedIsToday = widget.todo!.isToday;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestNotificationPermission(
    TodoReminder reminder,
  ) async {
    if (reminder != TodoReminder.none) {
      final notifier = ref.read(notificationServiceProvider);
      final granted = await notifier.requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Notification permissions are required for reminders.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        );
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(todoListProvider.notifier);
      if (widget.todo == null) {
        notifier.addTodo(
          _titleController.text,
          description: _descriptionController.text,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          category: _selectedCategory,
          isToday: _selectedIsToday,
          reminder: _selectedReminder,
        );
      } else {
        notifier.editTodo(
          widget.todo!.id,
          _titleController.text,
          newDescription: _descriptionController.text,
          newPriority: _selectedPriority,
          newDueDate: () => _selectedDueDate,
          newCategory: _selectedCategory,
          newIsToday: _selectedIsToday,
          newReminder: _selectedReminder,
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.todo != null;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28.0),
        topRight: Radius.circular(28.0),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 8.0,
          left: 24.0,
          right: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
        ),
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.85 -
                  MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 48.0,
                      height: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.4,
                        ),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    isEditing ? 'Edit Task' : 'New Task',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'What needs to be done?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      prefixIcon: const Icon(Icons.title_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Add details or notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      prefixIcon: const Icon(Icons.notes_rounded),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Category Selection
                  Text(
                    'Category',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: TodoCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category.label),
                        avatar: Icon(
                          category.icon,
                          size: 16.0,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor: theme.colorScheme.surfaceVariant
                            .withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant.withOpacity(
                                    0.5,
                                  ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20.0),
                  // Priority Selection
                  Text(
                    'Priority',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SegmentedButton<TodoPriority>(
                    segments: const [
                      ButtonSegment<TodoPriority>(
                        value: TodoPriority.low,
                        label: Text('Low'),
                      ),
                      ButtonSegment<TodoPriority>(
                        value: TodoPriority.medium,
                        label: Text('Medium'),
                      ),
                      ButtonSegment<TodoPriority>(
                        value: TodoPriority.high,
                        label: Text('High'),
                      ),
                    ],
                    selected: {_selectedPriority},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedPriority = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  // Due Date Selection
                  Text(
                    'Due Date',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: Text(
                            _selectedDueDate == null
                                ? 'No due date set'
                                : 'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 5),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedDueDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      if (_selectedDueDate != null) ...[
                        const SizedBox(width: 8.0),
                        IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          tooltip: 'Clear due date',
                          onPressed: () {
                            setState(() {
                              _selectedDueDate = null;
                              _selectedReminder = TodoReminder.none;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                  if (_selectedDueDate != null) ...[
                    const SizedBox(height: 16.0),
                    Text(
                      'Reminder',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<TodoReminder>(
                      value: _selectedReminder,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(
                          Icons.notifications_active_rounded,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      items: TodoReminder.values.map((reminder) {
                        return DropdownMenuItem<TodoReminder>(
                          value: reminder,
                          child: Text(reminder.label),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          setState(() {
                            _selectedReminder = value;
                          });
                          await _checkAndRequestNotificationPermission(value);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16.0),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Add to Today's Tasks",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: Text(
                      "Shows task in your Today view",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                    value: _selectedIsToday,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (value) {
                      setState(() {
                        _selectedIsToday = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8.0),
                      FilledButton(
                        onPressed: _submit,
                        child: Text(isEditing ? 'Save' : 'Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
