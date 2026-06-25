import 'package:flutter/material.dart';
import '../models/todo.dart';

class SmartParseResult {
  final String title;
  final DateTime? dueDate;
  final TodoPriority? priority;
  final TodoCategory? category;
  final TodoRepeat? repeatOption;
  final TimeOfDay? dueTime;

  SmartParseResult({
    required this.title,
    this.dueDate,
    this.priority,
    this.category,
    this.repeatOption,
    this.dueTime,
  });
}

class SmartTaskParserService {
  static SmartParseResult parse(String input) {
    String workingText = input;

    TodoPriority? priority;
    TodoCategory? category;
    TodoRepeat? repeatOption;
    DateTime? dueDate;
    TimeOfDay? dueTime;

    // Helper to remove match and surrounding whitespaces cleanly
    String cleanAfterRemoval(String text, RegExp regExp) {
      return text.replaceFirst(regExp, ' ');
    }

    // 1. Parse Priority (low, medium, high)
    final priorityRegex = RegExp(
      r'\b(low|medium|high)\b',
      caseSensitive: false,
    );
    final priorityMatch = priorityRegex.firstMatch(workingText);
    if (priorityMatch != null) {
      final value = priorityMatch.group(1)!.toLowerCase();
      if (value == 'low') priority = TodoPriority.low;
      if (value == 'medium') priority = TodoPriority.medium;
      if (value == 'high') priority = TodoPriority.high;
      workingText = cleanAfterRemoval(workingText, priorityRegex);
    }

    // 2. Parse Category (personal, work, study, errands, other)
    final categoryRegex = RegExp(
      r'\b(personal|work|study|errands|other)\b',
      caseSensitive: false,
    );
    final categoryMatch = categoryRegex.firstMatch(workingText);
    if (categoryMatch != null) {
      final value = categoryMatch.group(1)!.toLowerCase();
      if (value == 'personal') category = TodoCategory.personal;
      if (value == 'work') category = TodoCategory.work;
      if (value == 'study') category = TodoCategory.study;
      if (value == 'errands') category = TodoCategory.errands;
      if (value == 'other') category = TodoCategory.other;
      workingText = cleanAfterRemoval(workingText, categoryRegex);
    }

    // 3. Parse Repeat Option (daily, weekly, monthly)
    final repeatRegex = RegExp(
      r'\b(daily|weekly|monthly)\b',
      caseSensitive: false,
    );
    final repeatMatch = repeatRegex.firstMatch(workingText);
    if (repeatMatch != null) {
      final value = repeatMatch.group(1)!.toLowerCase();
      if (value == 'daily') repeatOption = TodoRepeat.daily;
      if (value == 'weekly') repeatOption = TodoRepeat.weekly;
      if (value == 'monthly') repeatOption = TodoRepeat.monthly;
      workingText = cleanAfterRemoval(workingText, repeatRegex);
    }

    // 4. Parse Time
    // A. 12-hour format: 9am, 9:30am, 2pm, 12pm, etc.
    final time12Regex = RegExp(
      r'\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b',
      caseSensitive: false,
    );
    final time12Match = time12Regex.firstMatch(workingText);
    if (time12Match != null) {
      final hourStr = time12Match.group(1)!;
      final minStr = time12Match.group(2);
      final amPm = time12Match.group(3)!.toLowerCase();

      int hour = int.parse(hourStr);
      int minute = minStr != null ? int.parse(minStr) : 0;

      if (hour >= 1 && hour <= 12 && minute >= 0 && minute <= 59) {
        if (amPm == 'pm' && hour < 12) {
          hour += 12;
        } else if (amPm == 'am' && hour == 12) {
          hour = 0;
        }
        dueTime = TimeOfDay(hour: hour, minute: minute);
        workingText = cleanAfterRemoval(workingText, time12Regex);
      }
    } else {
      // B. 24-hour format: 14:00, 09:30, etc.
      final time24Regex = RegExp(r'\b(\d{1,2}):(\d{2})\b');
      final time24Match = time24Regex.firstMatch(workingText);
      if (time24Match != null) {
        final hourStr = time24Match.group(1)!;
        final minStr = time24Match.group(2)!;

        int hour = int.parse(hourStr);
        int minute = int.parse(minStr);

        if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
          dueTime = TimeOfDay(hour: hour, minute: minute);
          workingText = cleanAfterRemoval(workingText, time24Regex);
        }
      }
    }

    // 5. Parse Due Date Words
    // A. next week
    final nextWeekRegex = RegExp(r'\bnext\s+week\b', caseSensitive: false);
    if (nextWeekRegex.hasMatch(workingText)) {
      final now = DateTime.now();
      dueDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 7));
      workingText = cleanAfterRemoval(workingText, nextWeekRegex);
    } else {
      // B. today, tomorrow
      final dateWordRegex = RegExp(
        r'\b(today|tomorrow)\b',
        caseSensitive: false,
      );
      final dateWordMatch = dateWordRegex.firstMatch(workingText);
      if (dateWordMatch != null) {
        final value = dateWordMatch.group(1)!.toLowerCase();
        final now = DateTime.now();
        if (value == 'today') {
          dueDate = DateTime(now.year, now.month, now.day);
        } else if (value == 'tomorrow') {
          dueDate = DateTime(
            now.year,
            now.month,
            now.day,
          ).add(const Duration(days: 1));
        }
        workingText = cleanAfterRemoval(workingText, dateWordRegex);
      } else {
        // C. Weekdays: Monday...Sunday
        final weekdayRegex = RegExp(
          r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
          caseSensitive: false,
        );
        final weekdayMatch = weekdayRegex.firstMatch(workingText);
        if (weekdayMatch != null) {
          final value = weekdayMatch.group(1)!.toLowerCase();
          final weekdayMap = {
            'monday': 1,
            'tuesday': 2,
            'wednesday': 3,
            'thursday': 4,
            'friday': 5,
            'saturday': 6,
            'sunday': 7,
          };
          final targetWeekday = weekdayMap[value]!;
          final now = DateTime.now();
          int daysToAdd = targetWeekday - now.weekday;
          if (daysToAdd <= 0) {
            daysToAdd += 7;
          }
          dueDate = DateTime(
            now.year,
            now.month,
            now.day,
          ).add(Duration(days: daysToAdd));
          workingText = cleanAfterRemoval(workingText, weekdayRegex);
        }
      }
    }

    // If a time was detected but no due date was detected, default due date to today
    if (dueTime != null && dueDate == null) {
      final now = DateTime.now();
      dueDate = DateTime(now.year, now.month, now.day);
    }

    // Combine dueDate and dueTime if both exist
    if (dueDate != null && dueTime != null) {
      dueDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueTime.hour,
        dueTime.minute,
      );
    }

    // Clean up extra spaces in the remaining title
    final cleanTitle = workingText.replaceAll(RegExp(r'\s+'), ' ').trim();

    return SmartParseResult(
      title: cleanTitle,
      dueDate: dueDate,
      priority: priority,
      category: category,
      repeatOption: repeatOption,
      dueTime: dueTime,
    );
  }
}
