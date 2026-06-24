import 'package:flutter/material.dart';

enum TodoPriority { low, medium, high }

enum TodoCategory { personal, work, study, errands, other }

enum TodoReminder {
  none,
  atDueTime,
  tenMinutesBefore,
  oneHourBefore,
  oneDayBefore,
}

extension TodoCategoryExtension on TodoCategory {
  String get label {
    switch (this) {
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

  IconData get icon {
    switch (this) {
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

extension TodoPriorityExtension on TodoPriority {
  String get label {
    switch (this) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.high:
        return 'High';
    }
  }

  Color color(BuildContext context) {
    final theme = Theme.of(context);
    switch (this) {
      case TodoPriority.high:
        return theme.colorScheme.error;
      case TodoPriority.medium:
        return theme.colorScheme.tertiary;
      case TodoPriority.low:
        return theme.colorScheme.secondary;
    }
  }

  Color containerColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (this) {
      case TodoPriority.high:
        return theme.colorScheme.errorContainer;
      case TodoPriority.medium:
        return theme.colorScheme.tertiaryContainer;
      case TodoPriority.low:
        return theme.colorScheme.secondaryContainer;
    }
  }

  Color onContainerColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (this) {
      case TodoPriority.high:
        return theme.colorScheme.onErrorContainer;
      case TodoPriority.medium:
        return theme.colorScheme.onTertiaryContainer;
      case TodoPriority.low:
        return theme.colorScheme.onSecondaryContainer;
    }
  }
}

extension TodoReminderExtension on TodoReminder {
  String get label {
    switch (this) {
      case TodoReminder.none:
        return 'No reminder';
      case TodoReminder.atDueTime:
        return 'At due time';
      case TodoReminder.tenMinutesBefore:
        return '10 minutes before';
      case TodoReminder.oneHourBefore:
        return '1 hour before';
      case TodoReminder.oneDayBefore:
        return '1 day before';
    }
  }

  String get shortLabel {
    switch (this) {
      case TodoReminder.none:
        return '';
      case TodoReminder.atDueTime:
        return 'At due time';
      case TodoReminder.tenMinutesBefore:
        return '10m before';
      case TodoReminder.oneHourBefore:
        return '1h before';
      case TodoReminder.oneDayBefore:
        return '1d before';
    }
  }
}

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final TodoPriority priority;
  final DateTime? dueDate;
  final TodoCategory category;
  final bool isToday;
  final TodoReminder reminder;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.priority = TodoPriority.medium,
    this.dueDate,
    this.category = TodoCategory.other,
    this.isToday = false,
    this.reminder = TodoReminder.none,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    TodoPriority? priority,
    DateTime? Function()? dueDate,
    TodoCategory? category,
    bool? isToday,
    TodoReminder? reminder,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      category: category ?? this.category,
      isToday: isToday ?? this.isToday,
      reminder: reminder ?? this.reminder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'category': category.name,
      'isToday': isToday,
      'reminder': reminder.name,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    // Parse priority safely with default fallback for backward compatibility
    final priorityStr = json['priority'] as String?;
    final priority = TodoPriority.values.firstWhere(
      (e) => e.name == priorityStr,
      orElse: () => TodoPriority.medium,
    );

    // Parse dueDate safely, null if missing or invalid
    final dueDateStr = json['dueDate'] as String?;
    final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;

    // Parse category safely with default fallback for backward compatibility
    final categoryStr = json['category'] as String?;
    final category = TodoCategory.values.firstWhere(
      (e) => e.name == categoryStr,
      orElse: () => TodoCategory.other,
    );

    // Parse isToday safely with default fallback for backward compatibility
    final isToday = (json['isToday'] ?? false) as bool;

    // Parse reminder safely with default fallback for backward compatibility
    final reminderStr = json['reminder'] as String?;
    final reminder = TodoReminder.values.firstWhere(
      (e) => e.name == reminderStr,
      orElse: () => TodoReminder.none,
    );

    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      priority: priority,
      dueDate: dueDate,
      category: category,
      isToday: isToday,
      reminder: reminder,
    );
  }
}
