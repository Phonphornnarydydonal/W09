import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/todo.dart';
import '../dto/todo_dto.dart';
import 'repository_exception.dart';

class TodoRepository {
  static final global = TodoRepository(); 

  final List<Todo> fakeTodos = [
    Todo(id: '1', title: 'Buy groceries', completed: false),
    Todo(id: '2', title: 'Finish Flutter homework', completed: true),
    Todo(id: '3', title: 'Call the dentist', completed: false),
    Todo(id: '4', title: 'Read 20 pages of a book', completed: true),
    Todo(id: '5', title: 'Go for a 30-minute walk', completed: false),
  ];

  final String baseUrl =
      "https://datalist-72230-default-rtdb.asia-southeast1.firebasedatabase.app/.json";
  Future<List<Todo>> getTodos() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/todos.json"));

      if (response.statusCode != 200) {
        throw RepositoryException(
          "Failed to fetch tasks from server (${response.statusCode})",
        );
      }
      if (response.body == 'null' || response.body.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : Map.fromIterables(
              List.generate((decoded as List).length, (i) => 'todo${i + 1}'),
              List<dynamic>.from(decoded),
            );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return data.entries.map((entry) {
        return TodoDto.fromJson(entry.key, entry.value as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (e is RepositoryException) rethrow;
      print("REAL ERROR: $e");
      throw RepositoryException("No wifi !");
    }
  }

  Future<void> updateCompleted(String todoId, bool completed) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/todos/$todoId.json"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"completed": completed}),
    );
    if (response.statusCode != 200) {
      throw RepositoryException("Failed to update task ($todoId)");
    }
  }
}
