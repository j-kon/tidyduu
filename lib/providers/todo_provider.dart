import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';

// Enum for filtering task lists
enum TodoFilter {
  all,
  active,
  completed,
}

// Model for task statistics
class TodoStats {
  final int totalCount;
  final int activeCount;
  final int completedCount;
  final double completionPercentage;

  TodoStats({
    required this.totalCount,
    required this.activeCount,
    required this.completedCount,
  }) : completionPercentage = totalCount == 0 ? 0.0 : completedCount / totalCount;
}

// Provider for SharedPreferences instance (overridden in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized');
});

// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

// StateNotifierProvider for the todo list
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return TodoListNotifier(storageService);
});

// StateNotifier managing the todo list
class TodoListNotifier extends StateNotifier<List<Todo>> {
  final StorageService _storageService;

  TodoListNotifier(this._storageService) : super([]) {
    _loadTodos();
  }

  void _loadTodos() {
    state = _storageService.loadTodos();
  }

  void addTodo(
    String title, {
    String description = '',
    TodoPriority priority = TodoPriority.medium,
    DateTime? dueDate,
    TodoCategory category = TodoCategory.other,
    bool isToday = false,
  }) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;

    final newTodo = Todo(
      id: const Uuid().v4(),
      title: trimmedTitle,
      description: description.trim(),
      createdAt: DateTime.now(),
      priority: priority,
      dueDate: dueDate,
      category: category,
      isToday: isToday,
    );
    state = [...state, newTodo];
    _storageService.saveTodos(state);
  }

  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo
    ];
    _storageService.saveTodos(state);
  }

  void toggleToday(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isToday: !todo.isToday)
        else
          todo
    ];
    _storageService.saveTodos(state);
  }

  void editTodo(
    String id,
    String newTitle, {
    String newDescription = '',
    TodoPriority? newPriority,
    DateTime? Function()? newDueDate,
    TodoCategory? newCategory,
    bool? newIsToday,
  }) {
    final trimmedTitle = newTitle.trim();
    if (trimmedTitle.isEmpty) return;

    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(
            title: trimmedTitle,
            description: newDescription.trim(),
            priority: newPriority,
            dueDate: newDueDate,
            category: newCategory,
            isToday: newIsToday,
          )
        else
          todo
    ];
    _storageService.saveTodos(state);
  }

  void deleteTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
    _storageService.saveTodos(state);
  }

  void restoreTodo(Todo todo) {
    if (!state.any((t) => t.id == todo.id)) {
      state = [...state, todo];
      _storageService.saveTodos(state);
    }
  }
}

// StateProvider for the active filter
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// StateProvider for the active category filter (null means all categories)
final todoCategoryFilterProvider = StateProvider<TodoCategory?>((ref) => null);

// StateProvider for the search query
final todoSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider that calculates current filters and returns matching todos
final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);
  final categoryFilter = ref.watch(todoCategoryFilterProvider);
  final searchQuery = ref.watch(todoSearchQueryProvider).trim().toLowerCase();

  List<Todo> filtered = todos;

  // 1. Status Filter
  switch (filter) {
    case TodoFilter.completed:
      filtered = filtered.where((todo) => todo.isCompleted).toList();
      break;
    case TodoFilter.active:
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
      break;
    case TodoFilter.all:
    default:
      break;
  }

  // 2. Category Filter
  if (categoryFilter != null) {
    filtered = filtered.where((todo) => todo.category == categoryFilter).toList();
  }

  // 3. Search Query Filter (by title, case-insensitive)
  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((todo) => todo.title.toLowerCase().contains(searchQuery)).toList();
  }

  // Sort tasks:
  // 1. Completed stay lower
  // 2. High priority first (high -> index 2, medium -> index 1, low -> index 0)
  // 3. Nearest due date first
  // 4. Fallback: newest created first
  return filtered..sort((a, b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }

    if (a.priority != b.priority) {
      return b.priority.index.compareTo(a.priority.index);
    }

    if (a.dueDate != null && b.dueDate != null) {
      return a.dueDate!.compareTo(b.dueDate!);
    } else if (a.dueDate != null) {
      return -1;
    } else if (b.dueDate != null) {
      return 1;
    }

    return b.createdAt.compareTo(a.createdAt);
  });
});

// Provider that calculates stats of the todo list
final todoStatsProvider = Provider<TodoStats>((ref) {
  final todos = ref.watch(todoListProvider);
  final totalCount = todos.length;
  final completedCount = todos.where((todo) => todo.isCompleted).length;
  final activeCount = totalCount - completedCount;

  return TodoStats(
    totalCount: totalCount,
    activeCount: activeCount,
    completedCount: completedCount,
  );
});

enum AppTab {
  tasks,
  today,
  calendar,
}

// Navigation Tab Provider
final appTabProvider = StateProvider<AppTab>((ref) => AppTab.tasks);

// Selected date for Calendar view (without time)
final calendarSelectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Helper function to check if two dates are the same day (ignoring time)
bool _isSameDay(DateTime? a, DateTime b) {
  if (a == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// Provider for Today tasks:
// Show tasks due today OR marked as isToday.
final todayTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  final filtered = todos.where((todo) {
    return _isSameDay(todo.dueDate, todayStart) || todo.isToday;
  }).toList();

  // Sort: completed bottom, then priority, then due date, then newest created
  return filtered..sort((a, b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }
    if (a.priority != b.priority) {
      return b.priority.index.compareTo(a.priority.index);
    }
    if (a.dueDate != null && b.dueDate != null) {
      return a.dueDate!.compareTo(b.dueDate!);
    } else if (a.dueDate != null) {
      return -1;
    } else if (b.dueDate != null) {
      return 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  });
});

// Provider that calculates stats of the today's todo list
final todayStatsProvider = Provider<TodoStats>((ref) {
  final todos = ref.watch(todayTodoListProvider);
  final totalCount = todos.length;
  final completedCount = todos.where((todo) => todo.isCompleted).length;
  final activeCount = totalCount - completedCount;

  return TodoStats(
    totalCount: totalCount,
    activeCount: activeCount,
    completedCount: completedCount,
  );
});

// Provider for Calendar tasks for selected date
final calendarTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final selectedDate = ref.watch(calendarSelectedDateProvider);

  final filtered = todos.where((todo) {
    return _isSameDay(todo.dueDate, selectedDate);
  }).toList();

  // Sort: completed bottom, then priority, then newest created
  return filtered..sort((a, b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }
    if (a.priority != b.priority) {
      return b.priority.index.compareTo(a.priority.index);
    }
    return b.createdAt.compareTo(a.createdAt);
  });
});
