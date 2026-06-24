import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  final SharedPreferences _prefs;
  static const String _todosKey = 'tidyduu_todos';

  StorageService(this._prefs);

  List<Todo> loadTodos() {
    final String? todosJson = _prefs.getString(_todosKey);
    if (todosJson == null) {
      return [];
    }
    try {
      final List<dynamic> decodedList = jsonDecode(todosJson) as List<dynamic>;
      return decodedList.map((item) => Todo.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Return empty list if parsing fails
      return [];
    }
  }

  Future<bool> saveTodos(List<Todo> todos) async {
    final List<Map<String, dynamic>> jsonList = todos.map((todo) => todo.toJson()).toList();
    final String encoded = jsonEncode(jsonList);
    return await _prefs.setString(_todosKey, encoded);
  }
}
