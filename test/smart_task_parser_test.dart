import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tidyduu/models/todo.dart';
import 'package:tidyduu/services/smart_task_parser_service.dart';

void main() {
  group('SmartTaskParserService Tests', () {
    test('Buy groceries tomorrow', () {
      final result = SmartTaskParserService.parse('Buy groceries tomorrow');
      expect(result.title, 'Buy groceries');
      expect(result.dueDate, isNotNull);

      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
      expect(
        DateTime(
          result.dueDate!.year,
          result.dueDate!.month,
          result.dueDate!.day,
        ),
        tomorrow,
      );
      expect(result.dueTime, isNull);
      expect(result.priority, isNull);
      expect(result.category, isNull);
      expect(result.repeatOption, isNull);
    });

    test('Submit report Friday high work', () {
      final result = SmartTaskParserService.parse(
        'Submit report Friday high work',
      );
      expect(result.title, 'Submit report');
      expect(result.dueDate, isNotNull);
      expect(result.priority, TodoPriority.high);
      expect(result.category, TodoCategory.work);
      expect(result.repeatOption, isNull);
    });

    test('Read Flutter docs today medium study', () {
      final result = SmartTaskParserService.parse(
        'Read Flutter docs today medium study',
      );
      expect(result.title, 'Read Flutter docs');
      expect(result.dueDate, isNotNull);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(
        DateTime(
          result.dueDate!.year,
          result.dueDate!.month,
          result.dueDate!.day,
        ),
        today,
      );

      expect(result.priority, TodoPriority.medium);
      expect(result.category, TodoCategory.study);
      expect(result.repeatOption, isNull);
    });

    test('Pay electricity bill tomorrow 9am high personal', () {
      final result = SmartTaskParserService.parse(
        'Pay electricity bill tomorrow 9am high personal',
      );
      expect(result.title, 'Pay electricity bill');
      expect(result.dueDate, isNotNull);

      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
      expect(result.dueDate!.year, tomorrow.year);
      expect(result.dueDate!.month, tomorrow.month);
      expect(result.dueDate!.day, tomorrow.day);
      expect(result.dueDate!.hour, 9);
      expect(result.dueDate!.minute, 0);

      expect(result.dueTime, const TimeOfDay(hour: 9, minute: 0));
      expect(result.priority, TodoPriority.high);
      expect(result.category, TodoCategory.personal);
      expect(result.repeatOption, isNull);
    });

    test('Workout daily medium personal', () {
      final result = SmartTaskParserService.parse(
        'Workout daily medium personal',
      );
      expect(result.title, 'Workout');
      expect(result.dueDate, isNull);
      expect(result.priority, TodoPriority.medium);
      expect(result.category, TodoCategory.personal);
      expect(result.repeatOption, TodoRepeat.daily);
    });

    test('Normal input with no special words', () {
      final result = SmartTaskParserService.parse('Walk the dog');
      expect(result.title, 'Walk the dog');
      expect(result.dueDate, isNull);
      expect(result.dueTime, isNull);
      expect(result.priority, isNull);
      expect(result.category, isNull);
      expect(result.repeatOption, isNull);
    });

    test('Time parsing 24-hour formats', () {
      final result1 = SmartTaskParserService.parse('Do project 14:30 work');
      expect(result1.title, 'Do project');
      expect(result1.dueDate, isNotNull);
      expect(result1.dueDate!.hour, 14);
      expect(result1.dueDate!.minute, 30);
      expect(result1.category, TodoCategory.work);

      final result2 = SmartTaskParserService.parse('Morning review 08:00');
      expect(result2.title, 'Morning review');
      expect(result2.dueDate, isNotNull);
      expect(result2.dueDate!.hour, 8);
      expect(result2.dueDate!.minute, 0);
    });

    test('Next week date calculation', () {
      final result = SmartTaskParserService.parse(
        'Travel plans next week personal',
      );
      expect(result.title, 'Travel plans');
      expect(result.dueDate, isNotNull);

      final now = DateTime.now();
      final nextWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 7));
      expect(
        DateTime(
          result.dueDate!.year,
          result.dueDate!.month,
          result.dueDate!.day,
        ),
        nextWeek,
      );
      expect(result.category, TodoCategory.personal);
    });
  });
}
