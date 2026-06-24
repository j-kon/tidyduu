enum TodoPriority {
  low,
  medium,
  high,
}

enum TodoCategory {
  personal,
  work,
  study,
  errands,
  other,
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

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.priority = TodoPriority.medium,
    this.dueDate,
    this.category = TodoCategory.other,
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

    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] ?? '') as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      priority: priority,
      dueDate: dueDate,
      category: category,
    );
  }
}
