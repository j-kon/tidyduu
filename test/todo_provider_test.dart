import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidyduu/models/todo.dart';
import 'package:tidyduu/providers/todo_provider.dart';
import 'package:tidyduu/services/storage_service.dart';

void main() {
  late SharedPreferences prefs;
  late StorageService storageService;
  final testDate = DateTime(2026, 6, 24, 12, 0);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
  });

  ProviderContainer createContainer({
    List<Override> overrides = const [],
  }) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  group('Todo Provider Tests', () {
    test('Initial state is empty', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      expect(container.read(todoListProvider), isEmpty);
    });

    test('Add todo updates list state', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Buy milk', description: 'Organic preferred', priority: TodoPriority.low, dueDate: testDate);

      final todos = container.read(todoListProvider);
      expect(todos.length, 1);
      expect(todos.first.title, 'Buy milk');
      expect(todos.first.description, 'Organic preferred');
      expect(todos.first.isCompleted, isFalse);
      expect(todos.first.priority, TodoPriority.low);
      expect(todos.first.dueDate, testDate);

      // Verify it persists in storage
      final loaded = storageService.loadTodos();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'Buy milk');
      expect(loaded.first.priority, TodoPriority.low);
      expect(loaded.first.dueDate, testDate);
    });

    test('Cannot add or edit todo with empty or whitespace title', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final notifier = container.read(todoListProvider.notifier);
      
      // Attempt to add empty title
      notifier.addTodo('   ');
      expect(container.read(todoListProvider), isEmpty);

      // Add a valid todo
      notifier.addTodo('Valid Task');
      expect(container.read(todoListProvider).length, 1);
      final todoId = container.read(todoListProvider).first.id;

      // Attempt to edit to an empty title
      notifier.editTodo(todoId, '   ');
      // Title should remain unchanged
      expect(container.read(todoListProvider).first.title, 'Valid Task');
    });

    test('Toggle todo changes completion status', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Read book');
      final todoId = container.read(todoListProvider).first.id;

      notifier.toggleTodo(todoId);
      expect(container.read(todoListProvider).first.isCompleted, isTrue);

      notifier.toggleTodo(todoId);
      expect(container.read(todoListProvider).first.isCompleted, isFalse);
    });

    test('Edit todo updates title, description, priority and due date', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Old title', description: 'Old desc', priority: TodoPriority.medium);
      final todoId = container.read(todoListProvider).first.id;

      notifier.editTodo(
        todoId, 
        'New title', 
        newDescription: 'New desc',
        newPriority: TodoPriority.high,
        newDueDate: () => testDate,
      );
      
      final todo = container.read(todoListProvider).first;
      expect(todo.title, 'New title');
      expect(todo.description, 'New desc');
      expect(todo.priority, TodoPriority.high);
      expect(todo.dueDate, testDate);
    });

    test('Delete todo removes it from state', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('To delete');
      final todoId = container.read(todoListProvider).first.id;

      notifier.deleteTodo(todoId);
      expect(container.read(todoListProvider), isEmpty);
    });

    test('Restore todo adds it back to state', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Undo Task');
      final todo = container.read(todoListProvider).first;

      notifier.deleteTodo(todo.id);
      expect(container.read(todoListProvider), isEmpty);

      notifier.restoreTodo(todo);
      final restored = container.read(todoListProvider);
      expect(restored.length, 1);
      expect(restored.first.id, todo.id);
      expect(restored.first.title, 'Undo Task');
    });

    test('Filtering returns correct lists', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Task 1');
      notifier.addTodo('Task 2');
      final todoId2 = container.read(todoListProvider)[1].id;
      notifier.toggleTodo(todoId2); // Task 2 completed

      // Default filter (All)
      expect(container.read(filteredTodoListProvider).length, 2);

      // Active filter
      container.read(todoFilterProvider.notifier).state = TodoFilter.active;
      final activeList = container.read(filteredTodoListProvider);
      expect(activeList.length, 1);
      expect(activeList.first.title, 'Task 1');

      // Completed filter
      container.read(todoFilterProvider.notifier).state = TodoFilter.completed;
      final completedList = container.read(filteredTodoListProvider);
      expect(completedList.length, 1);
      expect(completedList.first.title, 'Task 2');
    });

    test('Stats returns correct calculations', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Task 1');
      notifier.addTodo('Task 2');
      notifier.addTodo('Task 3');
      final todoId1 = container.read(todoListProvider)[0].id;
      notifier.toggleTodo(todoId1); // Task 1 completed

      final stats = container.read(todoStatsProvider);
      expect(stats.totalCount, 3);
      expect(stats.completedCount, 1);
      expect(stats.activeCount, 2);
      expect(stats.completionPercentage, closeTo(1 / 3, 0.01));
    });

    test('filteredTodoListProvider sorts correctly (completed bottom, then priority, then due date)', () {
      final container = createContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final notifier = container.read(todoListProvider.notifier);
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final nextWeek = today.add(const Duration(days: 7));

      // Add a mix of tasks
      notifier.addTodo('Medium Priority, tomorrow', priority: TodoPriority.medium, dueDate: tomorrow);
      notifier.addTodo('High Priority, next week', priority: TodoPriority.high, dueDate: nextWeek);
      notifier.addTodo('Low Priority, today', priority: TodoPriority.low, dueDate: today);
      notifier.addTodo('High Priority, today', priority: TodoPriority.high, dueDate: today);
      notifier.addTodo('Completed task', priority: TodoPriority.high, dueDate: today);

      final todos = container.read(todoListProvider);
      // Toggle the 5th task to completed
      notifier.toggleTodo(todos[4].id);

      final sorted = container.read(filteredTodoListProvider);

      // We expect the sorting order:
      // 1. High Priority, today (active, high priority, nearest due date)
      // 2. High Priority, next week (active, high priority, farther due date)
      // 3. Medium Priority, tomorrow (active, medium priority)
      // 4. Low Priority, today (active, low priority)
      // 5. Completed task (completed always stays at bottom)
      expect(sorted[0].title, 'High Priority, today');
      expect(sorted[1].title, 'High Priority, next week');
      expect(sorted[2].title, 'Medium Priority, tomorrow');
      expect(sorted[3].title, 'Low Priority, today');
      expect(sorted[4].title, 'Completed task');
    });
  });
}
