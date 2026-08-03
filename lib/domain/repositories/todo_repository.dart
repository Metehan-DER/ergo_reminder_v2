import '../entities/todo_entity.dart';

/// TodoRepository — Görev veritabanı için domain katmanı soyutlaması.
///
/// [saveTodos] dış arayüze açık değil — ISP gereği yalnızca
/// kullanıcının ihtiyaç duyduğu operasyonlar burada tanımlanır.
/// Toplu kaydetme işlemi, implementasyon detayı olarak [TodoRepositoryImpl]'de
/// private kalır.
abstract class TodoRepository {
  Future<List<TodoItem>> getTodos();
  Future<void> addTodo(TodoItem todo);
  Future<void> updateTodo(TodoItem todo);
  Future<void> deleteTodo(String id);
}
