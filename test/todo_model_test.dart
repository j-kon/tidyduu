import 'package:flutter_test/flutter_test.dart';
import 'package:tidyduu/models/todo.dart';

void main() {
  group('Todo Model Unit Tests', () {
    final testDate = DateTime(2026, 6, 24, 12, 0);
    final dueTestDate = DateTime(2026, 6, 28, 12, 0);

    test('Instantiation sets correct fields', () {
      final subtasks = [
        Subtask(id: 's1', title: 'Subtask 1', isCompleted: true),
        Subtask(id: 's2', title: 'Subtask 2', isCompleted: false),
      ];

      final todo = Todo(
        id: '123',
        title: 'Task Title',
        description: 'Task Description',
        isCompleted: true,
        createdAt: testDate,
        priority: TodoPriority.high,
        dueDate: dueTestDate,
        category: TodoCategory.work,
        isToday: true,
        reminder: TodoReminder.oneHourBefore,
        notes: 'Persistent notes text',
        subtasks: subtasks,
        repeatOption: TodoRepeat.daily,
        updatedAt: testDate.add(const Duration(hours: 2)),
      );

      expect(todo.id, '123');
      expect(todo.title, 'Task Title');
      expect(todo.description, 'Task Description');
      expect(todo.isCompleted, isTrue);
      expect(todo.createdAt, testDate);
      expect(todo.priority, TodoPriority.high);
      expect(todo.dueDate, dueTestDate);
      expect(todo.category, TodoCategory.work);
      expect(todo.isToday, isTrue);
      expect(todo.reminder, TodoReminder.oneHourBefore);
      expect(todo.notes, 'Persistent notes text');
      expect(todo.subtasks, subtasks);
      expect(todo.repeatOption, TodoRepeat.daily);
      expect(todo.updatedAt, testDate.add(const Duration(hours: 2)));
    });

    test('Instantiation defaults correctly', () {
      final todo = Todo(id: '123', title: 'Task Title', createdAt: testDate);

      expect(todo.isCompleted, isFalse);
      expect(todo.description, '');
      expect(todo.priority, TodoPriority.medium);
      expect(todo.dueDate, isNull);
      expect(todo.category, TodoCategory.other);
      expect(todo.isToday, isFalse);
      expect(todo.reminder, TodoReminder.none);
      expect(todo.notes, '');
      expect(todo.subtasks, isEmpty);
      expect(todo.repeatOption, TodoRepeat.none);
      expect(todo.updatedAt, testDate);
    });

    test('copyWith modifies specific fields while retaining others', () {
      final original = Todo(
        id: '123',
        title: 'Original Title',
        description: 'Original Desc',
        isCompleted: false,
        createdAt: testDate,
        priority: TodoPriority.low,
        dueDate: dueTestDate,
        category: TodoCategory.personal,
        isToday: false,
        reminder: TodoReminder.none,
        notes: 'Original Notes',
        subtasks: [Subtask(id: 's1', title: 'Sub 1')],
        repeatOption: TodoRepeat.none,
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        isCompleted: true,
        priority: TodoPriority.high,
        dueDate: () => null,
        category: TodoCategory.study,
        isToday: true,
        reminder: TodoReminder.tenMinutesBefore,
        notes: 'Updated Notes',
        subtasks: [],
        repeatOption: TodoRepeat.weekly,
        updatedAt: testDate.add(const Duration(days: 1)),
      );

      expect(updated.title, 'Updated Title');
      expect(updated.isCompleted, isTrue);
      expect(updated.priority, TodoPriority.high);
      expect(updated.dueDate, isNull);
      expect(updated.category, TodoCategory.study);
      expect(updated.isToday, isTrue);
      expect(updated.reminder, TodoReminder.tenMinutesBefore);
      expect(updated.notes, 'Updated Notes');
      expect(updated.subtasks, isEmpty);
      expect(updated.repeatOption, TodoRepeat.weekly);
      expect(updated.updatedAt, testDate.add(const Duration(days: 1)));

      // Unchanged fields
      expect(updated.id, '123');
      expect(updated.description, 'Original Desc');
      expect(updated.createdAt, testDate);
    });

    test('toJson serializes fields correctly', () {
      final todo = Todo(
        id: '123',
        title: 'Task Title',
        description: 'Task Desc',
        isCompleted: false,
        createdAt: testDate,
        priority: TodoPriority.medium,
        dueDate: dueTestDate,
        category: TodoCategory.errands,
        isToday: true,
        reminder: TodoReminder.oneHourBefore,
        notes: 'Some notes',
        subtasks: [Subtask(id: 's1', title: 'S1', isCompleted: true)],
        repeatOption: TodoRepeat.monthly,
      );

      final json = todo.toJson();

      expect(json, {
        'id': '123',
        'title': 'Task Title',
        'description': 'Task Desc',
        'isCompleted': false,
        'createdAt': testDate.toIso8601String(),
        'priority': 'medium',
        'dueDate': dueTestDate.toIso8601String(),
        'category': 'errands',
        'isToday': true,
        'reminder': 'oneHourBefore',
        'notes': 'Some notes',
        'subtasks': [
          {'id': 's1', 'title': 'S1', 'isCompleted': true},
        ],
        'repeatOption': 'monthly',
        'updatedAt': testDate.toIso8601String(),
      });
    });

    test('fromJson parses valid JSON correctly', () {
      final json = {
        'id': '123',
        'title': 'Task Title',
        'description': 'Task Desc',
        'isCompleted': true,
        'createdAt': testDate.toIso8601String(),
        'priority': 'high',
        'dueDate': dueTestDate.toIso8601String(),
        'category': 'personal',
        'isToday': true,
        'reminder': 'oneHourBefore',
        'notes': 'New notes',
        'subtasks': [
          {'id': 's1', 'title': 'Sub1', 'isCompleted': false},
        ],
        'repeatOption': 'daily',
        'updatedAt': testDate.toIso8601String(),
      };

      final todo = Todo.fromJson(json);

      expect(todo.id, '123');
      expect(todo.title, 'Task Title');
      expect(todo.description, 'Task Desc');
      expect(todo.isCompleted, isTrue);
      expect(todo.createdAt, testDate);
      expect(todo.priority, TodoPriority.high);
      expect(todo.dueDate, dueTestDate);
      expect(todo.category, TodoCategory.personal);
      expect(todo.isToday, isTrue);
      expect(todo.reminder, TodoReminder.oneHourBefore);
      expect(todo.notes, 'New notes');
      expect(todo.subtasks.first.title, 'Sub1');
      expect(todo.repeatOption, TodoRepeat.daily);
      expect(todo.updatedAt, testDate);
    });

    test('fromJson parses legacy JSON safely defaulting new fields', () {
      final json = {
        'id': '123',
        'title': 'Task Title',
        'description': 'Task Desc',
        'isCompleted': true,
        'createdAt': testDate.toIso8601String(),
      };

      final todo = Todo.fromJson(json);

      expect(todo.id, '123');
      expect(todo.title, 'Task Title');
      expect(todo.category, TodoCategory.other);
      expect(todo.isToday, isFalse);
      expect(todo.reminder, TodoReminder.none);
      expect(todo.notes, '');
      expect(todo.subtasks, isEmpty);
      expect(todo.repeatOption, TodoRepeat.none);
      expect(todo.updatedAt, testDate);
    });
  });
}
