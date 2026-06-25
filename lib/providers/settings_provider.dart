import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import 'todo_provider.dart';

class AppSettings {
  final ThemeMode themeMode;
  final TodoPriority defaultPriority;
  final TodoReminder defaultReminder;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.defaultPriority = TodoPriority.medium,
    this.defaultReminder = TodoReminder.none,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    TodoPriority? defaultPriority,
    TodoReminder? defaultReminder,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultPriority: defaultPriority ?? this.defaultPriority,
      defaultReminder: defaultReminder ?? this.defaultReminder,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    final storage = _ref.read(storageServiceProvider);

    final themeStr = storage.getThemeMode();
    final priorityStr = storage.getDefaultPriority();
    final reminderStr = storage.getDefaultReminder();

    final themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeMode.system,
    );
    final defaultPriority = TodoPriority.values.firstWhere(
      (e) => e.name == priorityStr,
      orElse: () => TodoPriority.medium,
    );
    final defaultReminder = TodoReminder.values.firstWhere(
      (e) => e.name == reminderStr,
      orElse: () => TodoReminder.none,
    );

    state = AppSettings(
      themeMode: themeMode,
      defaultPriority: defaultPriority,
      defaultReminder: defaultReminder,
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _ref.read(storageServiceProvider).setThemeMode(mode.name);
  }

  Future<void> updateDefaultPriority(TodoPriority priority) async {
    state = state.copyWith(defaultPriority: priority);
    await _ref.read(storageServiceProvider).setDefaultPriority(priority.name);
  }

  Future<void> updateDefaultReminder(TodoReminder reminder) async {
    state = state.copyWith(defaultReminder: reminder);
    await _ref.read(storageServiceProvider).setDefaultReminder(reminder.name);
  }

  Future<void> clearCompletedTasks() async {
    final notifier = _ref.read(todoListProvider.notifier);
    final activeTodos = _ref
        .read(todoListProvider)
        .where((t) => !t.isCompleted)
        .toList();

    // Cancel notifications of completed tasks that we are deleting
    final completedTodos = _ref
        .read(todoListProvider)
        .where((t) => t.isCompleted)
        .toList();
    final notificationService = _ref.read(notificationServiceProvider);
    for (final todo in completedTodos) {
      await notificationService.cancelNotification(todo.id);
    }

    notifier.state = activeTodos;
    await _ref.read(storageServiceProvider).saveTodos(activeTodos);
  }

  Future<void> clearAllTasks() async {
    final notifier = _ref.read(todoListProvider.notifier);
    final notificationService = _ref.read(notificationServiceProvider);

    // Cancel all notifications
    for (final todo in notifier.state) {
      await notificationService.cancelNotification(todo.id);
    }

    notifier.state = [];
    await _ref.read(storageServiceProvider).clearAllTodos();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier(ref);
});
