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

enum TodoRepeat { none, daily, weekly, monthly }

extension TodoRepeatExtension on TodoRepeat {
  String get label {
    switch (this) {
      case TodoRepeat.none:
        return 'No repeat';
      case TodoRepeat.daily:
        return 'Daily';
      case TodoRepeat.weekly:
        return 'Weekly';
      case TodoRepeat.monthly:
        return 'Monthly';
    }
  }
}

class Subtask {
  final String id;
  final String title;
  final bool isCompleted;

  Subtask({required this.id, required this.title, this.isCompleted = false});

  Subtask copyWith({String? id, String? title, bool? isCompleted}) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isCompleted': isCompleted};
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }
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
  final String notes;
  final List<Subtask> subtasks;
  final TodoRepeat repeatOption;
  final DateTime updatedAt;
  final bool? isInMyDay;
  final int myDayOrder;
  final DateTime? myDayAddedAt;

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
    this.notes = '',
    this.subtasks = const [],
    this.repeatOption = TodoRepeat.none,
    DateTime? updatedAt,
    this.isInMyDay,
    this.myDayOrder = 0,
    this.myDayAddedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  bool get isPlannedForToday =>
      isInMyDay ??
      (isToday || (dueDate != null && _isSameDay(dueDate, DateTime.now())));

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
    String? notes,
    List<Subtask>? subtasks,
    TodoRepeat? repeatOption,
    DateTime? updatedAt,
    bool? Function()? isInMyDay,
    int? myDayOrder,
    DateTime? Function()? myDayAddedAt,
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
      notes: notes ?? this.notes,
      subtasks: subtasks ?? this.subtasks,
      repeatOption: repeatOption ?? this.repeatOption,
      updatedAt: updatedAt ?? this.updatedAt,
      isInMyDay: isInMyDay != null ? isInMyDay() : this.isInMyDay,
      myDayOrder: myDayOrder ?? this.myDayOrder,
      myDayAddedAt: myDayAddedAt != null ? myDayAddedAt() : this.myDayAddedAt,
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
      'notes': notes,
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
      'repeatOption': repeatOption.name,
      'updatedAt': updatedAt.toIso8601String(),
      'isInMyDay': isInMyDay,
      'myDayOrder': myDayOrder,
      'myDayAddedAt': myDayAddedAt?.toIso8601String(),
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

    // New fields with backward compatibility fallbacks
    final notes = (json['notes'] ?? '') as String;

    final subtasksList = json['subtasks'] as List<dynamic>?;
    final subtasks = subtasksList != null
        ? subtasksList
              .map((e) => Subtask.fromJson(e as Map<String, dynamic>))
              .toList()
        : const <Subtask>[];

    final repeatOptionStr = json['repeatOption'] as String?;
    final repeatOption = TodoRepeat.values.firstWhere(
      (e) => e.name == repeatOptionStr,
      orElse: () => TodoRepeat.none,
    );

    final createdAtStr = json['createdAt'] as String;
    final createdAt = DateTime.parse(createdAtStr);

    final updatedAtStr = json['updatedAt'] as String?;
    final updatedAt = updatedAtStr != null
        ? DateTime.parse(updatedAtStr)
        : createdAt;

    final isInMyDay = json['isInMyDay'] as bool?;
    final myDayOrder = (json['myDayOrder'] ?? 0) as int;
    final myDayAddedAtStr = json['myDayAddedAt'] as String?;
    final myDayAddedAt = myDayAddedAtStr != null ? DateTime.tryParse(myDayAddedAtStr) : null;

    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: createdAt,
      priority: priority,
      dueDate: dueDate,
      category: category,
      isToday: isToday,
      reminder: reminder,
      notes: notes,
      subtasks: subtasks,
      repeatOption: repeatOption,
      updatedAt: updatedAt,
      isInMyDay: isInMyDay,
      myDayOrder: myDayOrder,
      myDayAddedAt: myDayAddedAt,
    );
  }
}

bool _isSameDay(DateTime? a, DateTime b) {
  if (a == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
