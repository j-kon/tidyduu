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

  void addTodo(String title, {String description = ''}) {
    final newTodo = Todo(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
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

  void editTodo(String id, String newTitle, {String newDescription = ''}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(title: newTitle.trim(), description: newDescription.trim())
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

// Provider that calculates current filters and returns matching todos
final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.completed:
      return todos.where((todo) => todo.isCompleted).toList();
    case TodoFilter.active:
      return todos.where((todo) => !todo.isCompleted).toList();
    case TodoFilter.all:
    default:
      return todos;
  }
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
