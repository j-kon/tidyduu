import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidyduu/models/todo.dart';
import 'package:tidyduu/providers/todo_provider.dart';
import 'package:tidyduu/providers/focus_provider.dart';
import 'package:tidyduu/providers/dashboard_provider.dart';
import 'package:tidyduu/providers/settings_provider.dart';
import 'package:tidyduu/services/notification_service.dart';

class FakeNotificationService implements NotificationService {
  final List<Todo> scheduledTodos = [];
  final List<String> cancelledTodoIds = [];
  bool permissionsRequested = false;
  final List<String> instantNotifications = [];

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
  Future<void> showInstantNotification(String title, String body) async {
    instantNotifications.add('$title: $body');
  }
}

void main() {
  late ProviderContainer container;
  late SharedPreferences prefs;
  late FakeNotificationService fakeNotificationService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    fakeNotificationService = FakeNotificationService();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(fakeNotificationService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Dashboard Stats Tests', () {
    test('Calculates correct stats when list is empty', () {
      final stats = container.read(dashboardProvider);
      expect(stats.totalTasks, 0);
      expect(stats.completedTasks, 0);
      expect(stats.activeTasks, 0);
      expect(stats.overdueTasks, 0);
      expect(stats.currentStreak, 0);
    });

    test('Calculates stats, streak and priorities correctly', () {
      final notifier = container.read(todoListProvider.notifier);

      // Add tasks
      notifier.addTodo('Task 1', priority: TodoPriority.high);
      notifier.addTodo('Task 2', priority: TodoPriority.medium);

      // Complete Task 1
      final todo1 = container
          .read(todoListProvider)
          .firstWhere((t) => t.title == 'Task 1');
      notifier.toggleTodo(todo1.id);

      final stats = container.read(dashboardProvider);
      expect(stats.totalTasks, 2);
      expect(stats.completedTasks, 1);
      expect(stats.activeTasks, 1);
      expect(
        stats.highPriorityTasks,
        0,
      ); // Since the high priority one is completed
      expect(stats.completionPercentage, 0.5);
    });
  });

  group('Focus Timer Tests', () {
    test('Set focus task changes state', () {
      final notifier = container.read(focusTimerProvider.notifier);
      notifier.setFocusTask('test-id');

      final state = container.read(focusTimerProvider);
      expect(state.focusTodoId, 'test-id');
      expect(state.status, FocusTimerStatus.idle);
      expect(state.isBreak, isFalse);
    });

    test('Start, pause, reset timer', () {
      final notifier = container.read(focusTimerProvider.notifier);
      notifier.setFocusTask('test-id');

      notifier.start();
      expect(
        container.read(focusTimerProvider).status,
        FocusTimerStatus.running,
      );

      notifier.pause();
      expect(
        container.read(focusTimerProvider).status,
        FocusTimerStatus.paused,
      );

      notifier.reset();
      expect(container.read(focusTimerProvider).status, FocusTimerStatus.idle);
    });
  });

  group('Settings Provider Tests', () {
    test('Loads default settings', () {
      final settings = container.read(settingsProvider);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.defaultPriority, TodoPriority.medium);
    });

    test('Persists settings updates', () async {
      final notifier = container.read(settingsProvider.notifier);
      await notifier.updateThemeMode(ThemeMode.dark);
      await notifier.updateDefaultPriority(TodoPriority.high);

      final settings = container.read(settingsProvider);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.defaultPriority, TodoPriority.high);

      // Verify SharedPreferences persistence
      final storage = container.read(storageServiceProvider);
      expect(storage.getThemeMode(), 'dark');
      expect(storage.getDefaultPriority(), 'high');
    });
  });
}
