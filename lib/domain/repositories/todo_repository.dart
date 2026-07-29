import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> getTodos();
  Future<void> saveTodos(List<TodoItem> todos);
  Future<void> addTodo(TodoItem todo);
  Future<void> updateTodo(TodoItem todo);
  Future<void> deleteTodo(String id);
}
