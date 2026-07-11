import 'dart:convert';
import '../../models/todo.dart';

class TodoDto {
  static const id = "id";
  static const title = "title";
  static const completed = "completed";
  static Todo fromJson(String id, Map<String, dynamic> json) {
    assert(
      json.containsKey(title) && json[title] is String,
      "Missing or invalid title",
    );
    assert(
      json.containsKey(completed) && json[completed] is bool,
      "Missing or invalid completed status",
    );
    return Todo(
      id: id,
      title: json[title] as String,
      completed: json[completed] as bool,
    );
  }
  static Map<String, dynamic> toJson(Todo todo) {
    return {title: todo.title, completed: todo.completed};
  }
}

void main() {
  const jsonString = '''
  {
    "1": {
      "title": "Buy groceries",
      "completed": false
    },
    "2": {
      "title": "Finish Flutter homework",
      "completed": true
    },
    "3": {
      "title": "Call the dentist",
      "completed": false
    }
  }
  ''';
  final Map<String, dynamic> data = jsonDecode(jsonString);
  final List<Todo> todos = data.entries.map((entry) {
    final id = entry.key;
    final json = entry.value as Map<String, dynamic>;
    return TodoDto.fromJson(id, json);
  }).toList();
  for (var todo in todos) {
    print(
      "Todo ID: ${todo.id}, Title: ${todo.title}, Completed: ${todo.completed}",
    );
  }
}
