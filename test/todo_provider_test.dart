import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidyduu/models/todo.dart';
import 'package:tidyduu/providers/todo_provider.dart';
import 'package:tidyduu/services/notification_service.dart';
import 'package:tidyduu/services/storage_service.dart';

class FakeNotificationService implements NotificationService {
  final List<Todo> scheduledTodos = [];
  final List<String> cancelledTodoIds = [];
  bool permissionsRequested = false;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermissions() async {
    permissionsRequested = true;
    return true;
  }

  @override
  Future<void> scheduleNotification(Todo todo) async {
    scheduledTodos.add(todo);
  }

  @override
  Future<void> cancelNotification(String todoId) async {
    cancelledTodoIds.add(todoId);
  }

  @override
  Future<void> showInstantNotification(String title, String body) async {}
}

void main() {
  late SharedPreferences prefs;
  late StorageService storageService;
  late FakeNotificationService fakeNotificationService;
  final testDate = DateTime(2026, 6, 24, 12, 0);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    fakeNotificationService = FakeNotificationService();
  });

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(
      overrides: [
        notificationServiceProvider.overrideWithValue(fakeNotificationService),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Todo Provider Tests', () {
    test('Initial state is empty', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      expect(container.read(todoListProvider), isEmpty);
    });

    test('Add todo updates list state', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo(
        'Buy milk',
        description: 'Organic preferred',
        priority: TodoPriority.low,
        dueDate: testDate,
      );

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
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

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
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Read book');
      final todoId = container.read(todoListProvider).first.id;

      notifier.toggleTodo(todoId);
      expect(container.read(todoListProvider).first.isCompleted, isTrue);

      notifier.toggleTodo(todoId);
      expect(container.read(todoListProvider).first.isCompleted, isFalse);
    });

    test('Edit todo updates title, description, priority and due date', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo(
        'Old title',
        description: 'Old desc',
        priority: TodoPriority.medium,
      );
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
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('To delete');
      final todoId = container.read(todoListProvider).first.id;

      notifier.deleteTodo(todoId);
      expect(container.read(todoListProvider), isEmpty);
    });

    test('Restore todo adds it back to state', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

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
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

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
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

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

    test(
      'filteredTodoListProvider sorts correctly (completed bottom, then priority, then due date)',
      () {
        final container = createContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final notifier = container.read(todoListProvider.notifier);
        final today = DateTime.now();
        final tomorrow = today.add(const Duration(days: 1));
        final nextWeek = today.add(const Duration(days: 7));

        // Add a mix of tasks
        notifier.addTodo(
          'Medium Priority, tomorrow',
          priority: TodoPriority.medium,
          dueDate: tomorrow,
        );
        notifier.addTodo(
          'High Priority, next week',
          priority: TodoPriority.high,
          dueDate: nextWeek,
        );
        notifier.addTodo(
          'Low Priority, today',
          priority: TodoPriority.low,
          dueDate: today,
        );
        notifier.addTodo(
          'High Priority, today',
          priority: TodoPriority.high,
          dueDate: today,
        );
        notifier.addTodo(
          'Completed task',
          priority: TodoPriority.high,
          dueDate: today,
        );

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
      },
    );

    test('Filtering by category returns correct lists', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Personal Task 1', category: TodoCategory.personal);
      notifier.addTodo('Work Task 1', category: TodoCategory.work);
      notifier.addTodo('Study Task 1', category: TodoCategory.study);

      // Default category filter (All Categories / null)
      expect(container.read(filteredTodoListProvider).length, 3);

      // Filter by Work
      container.read(todoCategoryFilterProvider.notifier).state =
          TodoCategory.work;
      final workList = container.read(filteredTodoListProvider);
      expect(workList.length, 1);
      expect(workList.first.title, 'Work Task 1');

      // Filter by Study
      container.read(todoCategoryFilterProvider.notifier).state =
          TodoCategory.study;
      final studyList = container.read(filteredTodoListProvider);
      expect(studyList.length, 1);
      expect(studyList.first.title, 'Study Task 1');
    });

    test('Searching by title matches case-insensitive and filters lists', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Buy groceries');
      notifier.addTodo('Groceries shopping');
      notifier.addTodo('Clean bedroom');

      // Search for "groceries"
      container.read(todoSearchQueryProvider.notifier).state = 'groceries';
      final searchResult1 = container.read(filteredTodoListProvider);
      expect(searchResult1.length, 2);
      expect(searchResult1.any((t) => t.title == 'Buy groceries'), isTrue);
      expect(searchResult1.any((t) => t.title == 'Groceries shopping'), isTrue);

      // Search for "SHOP" (case-insensitive)
      container.read(todoSearchQueryProvider.notifier).state = 'SHOP';
      final searchResult2 = container.read(filteredTodoListProvider);
      expect(searchResult2.length, 1);
      expect(searchResult2.first.title, 'Groceries shopping');
    });

    test(
      'Searching, category filtering, and status filtering work in combination',
      () {
        final container = createContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final notifier = container.read(todoListProvider.notifier);
        notifier.addTodo(
          'Buy milk',
          category: TodoCategory.errands,
        ); // active, errands
        notifier.addTodo(
          'Buy coffee',
          category: TodoCategory.errands,
        ); // active, errands
        notifier.addTodo(
          'Clean office',
          category: TodoCategory.work,
        ); // active, work

        final todos = container.read(todoListProvider);
        // Mark 'Buy milk' as completed
        notifier.toggleTodo(todos[0].id); // completed, errands

        // Filter: Status=Active, Category=Errands, Search="Buy"
        container.read(todoFilterProvider.notifier).state = TodoFilter.active;
        container.read(todoCategoryFilterProvider.notifier).state =
            TodoCategory.errands;
        container.read(todoSearchQueryProvider.notifier).state = 'Buy';

        final result = container.read(filteredTodoListProvider);
        expect(result.length, 1);
        expect(result.first.title, 'Buy coffee');
      },
    );

    test('toggleToday changes isToday status', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Today Task');
      final todoId = container.read(todoListProvider).first.id;

      expect(container.read(todoListProvider).first.isToday, isFalse);

      notifier.toggleToday(todoId);
      expect(container.read(todoListProvider).first.isToday, isTrue);

      notifier.toggleToday(todoId);
      expect(container.read(todoListProvider).first.isToday, isFalse);
    });

    test(
      'todayTodoListProvider filters and todayStatsProvider calculates correctly',
      () {
        final container = createContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final notifier = container.read(todoListProvider.notifier);
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final tomorrow = todayStart.add(const Duration(days: 1));

        // Task 1: Due today, active
        notifier.addTodo('Due Today Task', dueDate: todayStart);
        // Task 2: Not due today, but isToday=true, active
        notifier.addTodo(
          'Starred Today Task',
          isToday: true,
          dueDate: tomorrow,
        );
        // Task 3: Due today, completed
        notifier.addTodo('Due Today Completed Task', dueDate: todayStart);
        // Task 4: Not due today, isToday=false, active
        notifier.addTodo('Future Task', dueDate: tomorrow);

        final todos = container.read(todoListProvider);
        // Toggle Task 3 to completed
        final task3Id = todos
            .firstWhere((t) => t.title == 'Due Today Completed Task')
            .id;
        notifier.toggleTodo(task3Id);

        // Verify todayTodoListProvider has 3 items (Task 1, 2, 3)
        final todayList = container.read(todayTodoListProvider);
        expect(todayList.length, 3);
        expect(todayList.any((t) => t.title == 'Due Today Task'), isTrue);
        expect(todayList.any((t) => t.title == 'Starred Today Task'), isTrue);
        expect(
          todayList.any((t) => t.title == 'Due Today Completed Task'),
          isTrue,
        );
        expect(todayList.any((t) => t.title == 'Future Task'), isFalse);

        // Verify stats
        final stats = container.read(todayStatsProvider);
        expect(stats.totalCount, 3);
        expect(stats.completedCount, 1);
        expect(stats.activeCount, 2);
      },
    );

    test(
      'calendarTodoListProvider filters correctly based on calendarSelectedDateProvider',
      () {
        final container = createContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final notifier = container.read(todoListProvider.notifier);
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final tomorrow = todayStart.add(const Duration(days: 1));

        notifier.addTodo('Today Task 1', dueDate: todayStart);
        notifier.addTodo('Today Task 2', dueDate: todayStart);
        notifier.addTodo('Tomorrow Task', dueDate: tomorrow);

        // By default calendarSelectedDateProvider is today
        final calendarListToday = container.read(calendarTodoListProvider);
        expect(calendarListToday.length, 2);
        expect(
          calendarListToday.any((t) => t.title == 'Tomorrow Task'),
          isFalse,
        );

        // Change calendarSelectedDateProvider to tomorrow
        container.read(calendarSelectedDateProvider.notifier).state = tomorrow;
        final calendarListTomorrow = container.read(calendarTodoListProvider);
        expect(calendarListTomorrow.length, 1);
        expect(calendarListTomorrow.first.title, 'Tomorrow Task');
      },
    );

    test('addTodo schedules a notification if a reminder is set', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo(
        'Reminder Task',
        dueDate: testDate,
        reminder: TodoReminder.oneHourBefore,
      );

      expect(fakeNotificationService.scheduledTodos.length, 1);
      expect(
        fakeNotificationService.scheduledTodos.first.title,
        'Reminder Task',
      );
      expect(
        fakeNotificationService.scheduledTodos.first.reminder,
        TodoReminder.oneHourBefore,
      );
    });

    test(
      'toggleTodo cancels notification when completed, and schedules when active',
      () {
        final container = createContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );

        final notifier = container.read(todoListProvider.notifier);
        notifier.addTodo(
          'Completable Task',
          dueDate: testDate,
          reminder: TodoReminder.atDueTime,
        );

        final todoId = container.read(todoListProvider).first.id;
        fakeNotificationService.scheduledTodos.clear();

        // Complete the task -> Should cancel notification
        notifier.toggleTodo(todoId);
        expect(
          fakeNotificationService.cancelledTodoIds.length,
          1,
        ); // 1 from toggle
        expect(fakeNotificationService.cancelledTodoIds.last, todoId);

        // Mark task as active -> Should reschedule notification
        notifier.toggleTodo(todoId);
        expect(fakeNotificationService.scheduledTodos.length, 1);
        expect(fakeNotificationService.scheduledTodos.first.id, todoId);
      },
    );

    test('editTodo updates notification schedule', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo(
        'Task to edit',
        dueDate: testDate,
        reminder: TodoReminder.atDueTime,
      );

      final todoId = container.read(todoListProvider).first.id;
      fakeNotificationService.scheduledTodos.clear();

      notifier.editTodo(
        todoId,
        'Updated Task title',
        newReminder: TodoReminder.tenMinutesBefore,
      );

      expect(fakeNotificationService.scheduledTodos.length, 1);
      expect(
        fakeNotificationService.scheduledTodos.first.title,
        'Updated Task title',
      );
      expect(
        fakeNotificationService.scheduledTodos.first.reminder,
        TodoReminder.tenMinutesBefore,
      );
    });

    test('deleteTodo cancels notification', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo(
        'Task to delete',
        dueDate: testDate,
        reminder: TodoReminder.atDueTime,
      );

      final todoId = container.read(todoListProvider).first.id;
      fakeNotificationService.cancelledTodoIds.clear();

      notifier.deleteTodo(todoId);
      expect(fakeNotificationService.cancelledTodoIds.length, 1);
      expect(fakeNotificationService.cancelledTodoIds.first, todoId);
    });

    test('addTodo saves subtasks, notes, and repeatOption', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      final subtasks = [Subtask(id: 's1', title: 'Sub 1')];
      notifier.addTodo(
        'Main Task',
        notes: 'Main notes',
        subtasks: subtasks,
        repeatOption: TodoRepeat.daily,
      );

      final todos = container.read(todoListProvider);
      expect(todos.length, 1);
      expect(todos.first.notes, 'Main notes');
      expect(todos.first.subtasks.first.title, 'Sub 1');
      expect(todos.first.repeatOption, TodoRepeat.daily);
    });

    test('toggleSubtask and subtask operations work correctly', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      notifier.addTodo('Main Task');

      final todoId = container.read(todoListProvider).first.id;

      // Add subtask
      notifier.addSubtask(todoId, 'Subtask 1');
      expect(container.read(todoListProvider).first.subtasks.length, 1);
      expect(
        container.read(todoListProvider).first.subtasks.first.title,
        'Subtask 1',
      );
      expect(
        container.read(todoListProvider).first.subtasks.first.isCompleted,
        isFalse,
      );

      final subtaskId = container
          .read(todoListProvider)
          .first
          .subtasks
          .first
          .id;

      // Edit subtask
      notifier.editSubtask(todoId, subtaskId, 'Subtask 1 Edited');
      expect(
        container.read(todoListProvider).first.subtasks.first.title,
        'Subtask 1 Edited',
      );

      // Toggle subtask
      notifier.toggleSubtask(todoId, subtaskId);
      expect(
        container.read(todoListProvider).first.subtasks.first.isCompleted,
        isTrue,
      );

      // Delete subtask
      notifier.deleteSubtask(todoId, subtaskId);
      expect(container.read(todoListProvider).first.subtasks, isEmpty);
    });

    test('toggleTodo on recurring task spawns next occurrence', () {
      final container = createContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final notifier = container.read(todoListProvider.notifier);
      final dueDate = DateTime(2026, 6, 24, 10, 0);
      notifier.addTodo(
        'Daily Task',
        dueDate: dueDate,
        repeatOption: TodoRepeat.daily,
        subtasks: [Subtask(id: 's1', title: 'Sub 1', isCompleted: true)],
      );

      final firstTodo = container.read(todoListProvider).first;
      final firstTodoId = firstTodo.id;

      fakeNotificationService.scheduledTodos.clear();

      // Complete the task -> Should toggle original to completed, spawn next occurrence
      notifier.toggleTodo(firstTodoId);

      final todos = container.read(todoListProvider);
      // Expect 2 todos: 1 completed, 1 new active
      expect(todos.length, 2);

      final completedTodo = todos.firstWhere((t) => t.id == firstTodoId);
      expect(completedTodo.isCompleted, isTrue);

      final spawnedTodo = todos.firstWhere((t) => t.id != firstTodoId);
      expect(spawnedTodo.isCompleted, isFalse);
      expect(spawnedTodo.title, 'Daily Task');
      expect(spawnedTodo.repeatOption, TodoRepeat.daily);
      expect(spawnedTodo.dueDate, dueDate.add(const Duration(days: 1)));
      expect(
        spawnedTodo.subtasks.first.isCompleted,
        isFalse,
      ); // resets subtasks completeness

      // Verify notification scheduled for next occurrence
      expect(fakeNotificationService.scheduledTodos.length, 1);
      expect(fakeNotificationService.scheduledTodos.first.id, spawnedTodo.id);
    });
  });
}
