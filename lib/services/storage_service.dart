import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  final SharedPreferences _prefs;
  static const String _todosKey = 'tidyduu_todos';

  StorageService(this._prefs);

  List<Todo> loadTodos() {
    try {
      final String? todosJson = _prefs.getString(_todosKey);
      if (todosJson == null) {
        return [];
      }
      final List<dynamic> decodedList = jsonDecode(todosJson) as List<dynamic>;
      return decodedList
          .map((item) => Todo.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('StorageService: Error loading todos: $e\n$stackTrace');
      return [];
    }
  }

  Future<bool> saveTodos(List<Todo> todos) async {
    try {
      final List<Map<String, dynamic>> jsonList = todos
          .map((todo) => todo.toJson())
          .toList();
      final String encoded = jsonEncode(jsonList);
      return await _prefs.setString(_todosKey, encoded);
    } catch (e, stackTrace) {
      debugPrint('StorageService: Error saving todos: $e\n$stackTrace');
      return false;
    }
  }

  String getThemeMode() => _prefs.getString('theme_mode') ?? 'system';
  Future<bool> setThemeMode(String value) =>
      _prefs.setString('theme_mode', value);

  String getDefaultPriority() =>
      _prefs.getString('default_priority') ?? 'medium';
  Future<bool> setDefaultPriority(String value) =>
      _prefs.setString('default_priority', value);

  String getDefaultReminder() => _prefs.getString('default_reminder') ?? 'none';
  Future<bool> setDefaultReminder(String value) =>
      _prefs.setString('default_reminder', value);

  static const String _customOrderKey = 'tidyduu_custom_order';

  List<String> loadCustomOrder() {
    try {
      return _prefs.getStringList(_customOrderKey) ?? [];
    } catch (e, stackTrace) {
      debugPrint('StorageService: Error loading custom order: $e\n$stackTrace');
      return [];
    }
  }

  Future<bool> saveCustomOrder(List<String> order) async {
    try {
      return await _prefs.setStringList(_customOrderKey, order);
    } catch (e, stackTrace) {
      debugPrint('StorageService: Error saving custom order: $e\n$stackTrace');
      return false;
    }
  }

  Future<bool> clearAllTodos() => _prefs.remove(_todosKey);
}
