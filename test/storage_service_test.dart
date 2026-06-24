import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidyduu/models/todo.dart';
import 'package:tidyduu/services/storage_service.dart';

void main() {
  late SharedPreferences prefs;
  late StorageService storageService;
  const String todosKey = 'tidyduu_todos';
  final testDate = DateTime(2026, 6, 24, 12, 0);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
  });

  group('StorageService Tests', () {
    test('loadTodos returns empty list when no data is saved', () {
      final todos = storageService.loadTodos();
      expect(todos, isEmpty);
    });

    test('saveTodos saves serialized todo items to SharedPreferences', () async {
      final todo = Todo(
        id: '123',
        title: 'Task title',
        description: 'Task desc',
        isCompleted: true,
        createdAt: testDate,
        priority: TodoPriority.high,
        dueDate: testDate,
      );

      final success = await storageService.saveTodos([todo]);
      expect(success, isTrue);

      // Verify what was written to SharedPreferences directly
      final savedString = prefs.getString(todosKey);
      expect(savedString, isNotNull);

      final decoded = jsonDecode(savedString!) as List<dynamic>;
      expect(decoded.length, 1);
      expect(decoded.first['id'], '123');
      expect(decoded.first['title'], 'Task title');
      expect(decoded.first['isCompleted'], isTrue);
      expect(decoded.first['priority'], 'high');
      expect(decoded.first['dueDate'], testDate.toIso8601String());
      expect(decoded.first['category'], 'other');
    });

    test('loadTodos deserializes saved tasks correctly', () async {
      final todo1 = Todo(id: '1', title: 'Task 1', createdAt: testDate, priority: TodoPriority.low);
      final todo2 = Todo(id: '2', title: 'Task 2', isCompleted: true, createdAt: testDate, dueDate: testDate);

      await storageService.saveTodos([todo1, todo2]);

      final loaded = storageService.loadTodos();
      expect(loaded.length, 2);

      expect(loaded[0].id, '1');
      expect(loaded[0].title, 'Task 1');
      expect(loaded[0].isCompleted, isFalse);
      expect(loaded[0].priority, TodoPriority.low);
      expect(loaded[0].dueDate, isNull);

      expect(loaded[1].id, '2');
      expect(loaded[1].title, 'Task 2');
      expect(loaded[1].isCompleted, isTrue);
      expect(loaded[1].priority, TodoPriority.medium);
      expect(loaded[1].dueDate, testDate);
    });

    test('loadTodos successfully parses legacy JSON without priority or dueDate fields', () async {
      // Create legacy JSON directly (no priority or dueDate fields)
      final legacyJson = [
        {
          'id': 'legacy-1',
          'title': 'Legacy Task',
          'description': 'Legacy Desc',
          'isCompleted': false,
          'createdAt': testDate.toIso8601String(),
        }
      ];
      await prefs.setString(todosKey, jsonEncode(legacyJson));

      final loaded = storageService.loadTodos();
      expect(loaded.length, 1);
      expect(loaded.first.id, 'legacy-1');
      expect(loaded.first.title, 'Legacy Task');
      // Fallback defaults:
      expect(loaded.first.priority, TodoPriority.medium);
      expect(loaded.first.dueDate, isNull);
      expect(loaded.first.category, TodoCategory.other);
    });

    test('loadTodos returns empty list and handles exception if JSON is corrupted', () async {
      // Write corrupted JSON directly to SharedPreferences
      await prefs.setString(todosKey, '{invalid json');

      final loaded = storageService.loadTodos();
      // Should handle exception and return empty list cleanly
      expect(loaded, isEmpty);
    });
  });
}
