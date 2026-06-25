import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import 'todo_provider.dart';

class DashboardStats {
  final int totalTasks;
  final int completedTasks;
  final int activeTasks;
  final int overdueTasks;
  final int todayTasks;
  final int highPriorityTasks;
  final double completionPercentage;
  final int currentStreak;

  DashboardStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.activeTasks,
    required this.overdueTasks,
    required this.todayTasks,
    required this.highPriorityTasks,
    required this.completionPercentage,
    required this.currentStreak,
  });
}

final dashboardProvider = Provider<DashboardStats>((ref) {
  final todos = ref.watch(todoListProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final total = todos.length;
  final completed = todos.where((t) => t.isCompleted).length;
  final active = total - completed;

  final overdue = todos.where((t) {
    if (t.isCompleted || t.dueDate == null) return false;
    final taskDue = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
    return taskDue.isBefore(today);
  }).length;

  final todayTasks = todos.where((t) {
    if (t.dueDate == null) return false;
    final taskDue = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
    return taskDue.year == today.year &&
        taskDue.month == today.month &&
        taskDue.day == today.day;
  }).length;

  final highPriority = todos
      .where((t) => !t.isCompleted && t.priority == TodoPriority.high)
      .length;

  final percentage = total == 0 ? 0.0 : completed / total;

  // Streak Calculation
  final completedDates =
      todos
          .where((t) => t.isCompleted)
          .map(
            (t) =>
                DateTime(t.updatedAt.year, t.updatedAt.month, t.updatedAt.day),
          )
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

  int streak = 0;
  if (completedDates.isNotEmpty) {
    final yesterday = today.subtract(const Duration(days: 1));
    if (completedDates.contains(today) || completedDates.contains(yesterday)) {
      DateTime checkDate = completedDates.contains(today) ? today : yesterday;
      while (completedDates.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }
  }

  return DashboardStats(
    totalTasks: total,
    completedTasks: completed,
    activeTasks: active,
    overdueTasks: overdue,
    todayTasks: todayTasks,
    highPriorityTasks: highPriority,
    completionPercentage: percentage,
    currentStreak: streak,
  );
});
