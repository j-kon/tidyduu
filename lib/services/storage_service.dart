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
}
