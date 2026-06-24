import 'package:flutter_test/flutter_test.dart';
import 'package:tidyduu/models/todo.dart';

void main() {
  group('Todo Model Unit Tests', () {
    final testDate = DateTime(2026, 6, 24, 12, 0);
    final dueTestDate = DateTime(2026, 6, 28, 12, 0);

    test('Instantiation sets correct fields', () {
      final todo = Todo(
        id: '123',
        title: 'Task Title',
        description: 'Task Description',
        isCompleted: true,
        createdAt: testDate,
        priority: TodoPriority.high,
        dueDate: dueTestDate,
      );

      expect(todo.id, '123');
      expect(todo.title, 'Task Title');
      expect(todo.description, 'Task Description');
      expect(todo.isCompleted, isTrue);
      expect(todo.createdAt, testDate);
      expect(todo.priority, TodoPriority.high);
      expect(todo.dueDate, dueTestDate);
    });

    test('Instantiation defaults correctly', () {
      final todo = Todo(
        id: '123',
        title: 'Task Title',
        createdAt: testDate,
      );

      expect(todo.isCompleted, isFalse);
      expect(todo.description, '');
      expect(todo.priority, TodoPriority.medium);
      expect(todo.dueDate, isNull);
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
      );

      // Copy with priority change and clearing due date
      final updated = original.copyWith(
        title: 'Updated Title',
        isCompleted: true,
        priority: TodoPriority.high,
        dueDate: () => null, // Reset due date to null
      );

      // Changed fields
      expect(updated.title, 'Updated Title');
      expect(updated.isCompleted, isTrue);
      expect(updated.priority, TodoPriority.high);
      expect(updated.dueDate, isNull);

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
      };

      final todo = Todo.fromJson(json);

      expect(todo.id, '123');
      expect(todo.title, 'Task Title');
      expect(todo.description, 'Task Desc');
      expect(todo.isCompleted, isTrue);
      expect(todo.createdAt, testDate);
      expect(todo.priority, TodoPriority.high);
      expect(todo.dueDate, dueTestDate);
    });
  });
}
