import 'dart:convert';
import '../../core/services/storage_service.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final StorageService _storageService;
  static const String _todosKey = 'user_todos_v1';

  TodoRepositoryImpl(this._storageService);

  @override
  Future<List<TodoItem>> getTodos() async {
    final jsonString = _storageService.getString(_todosKey, defaultValue: '[]');
    if (jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => TodoItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveTodos(List<TodoItem> todos) async {
    final jsonList = todos.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _storageService.setString(_todosKey, jsonString);
  }

  @override
  Future<void> addTodo(TodoItem todo) async {
    final todos = await getTodos();
    todos.insert(0, todo);
    await saveTodos(todos);
  }

  @override
  Future<void> updateTodo(TodoItem todo) async {
    final todos = await getTodos();
    final index = todos.indexWhere((e) => e.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      await saveTodos(todos);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = await getTodos();
    todos.removeWhere((e) => e.id == id);
    await saveTodos(todos);
  }
}
