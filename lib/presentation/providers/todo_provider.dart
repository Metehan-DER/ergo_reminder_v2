import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo_entity.dart';
import 'repository_providers.dart';

enum TodoFilter { all, today, pending, completed }

class TodoState {
  final List<TodoItem> todos;
  final TodoFilter filter;
  final String searchQuery;
  final bool isLoading;

  TodoState({
    this.todos = const [],
    this.filter = TodoFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
  });

  TodoState copyWith({
    List<TodoItem>? todos,
    TodoFilter? filter,
    String? searchQuery,
    bool? isLoading,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<TodoItem> get filteredTodos {
    final now = DateTime.now();
    return todos.where((todo) {
      // Search query filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = todo.title.toLowerCase().contains(query);
        final matchesDesc = todo.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }

      // Filter logic
      switch (filter) {
        case TodoFilter.today:
          if (todo.dueDate == null) return false;
          return todo.dueDate!.year == now.year &&
              todo.dueDate!.month == now.month &&
              todo.dueDate!.day == now.day;
        case TodoFilter.pending:
          return !todo.isCompleted;
        case TodoFilter.completed:
          return todo.isCompleted;
        case TodoFilter.all:
          return true;
      }
    }).toList();
  }

  int get pendingCount => todos.where((t) => !t.isCompleted).length;
  int get completedCount => todos.where((t) => t.isCompleted).length;
  int get todayCount {
    final now = DateTime.now();
    return todos.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).length;
  }
}

class TodoNotifier extends Notifier<TodoState> {
  @override
  TodoState build() {
    // Load todos asynchronously after build
    Future.microtask(() => loadTodos());
    return TodoState(isLoading: true);
  }

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(todoRepositoryProvider);
    final todos = await repo.getTodos();
    state = state.copyWith(todos: todos, isLoading: false);
  }

  Future<void> addTodo(TodoItem item) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.addTodo(item);
    await loadTodos();
  }

  Future<void> toggleTodo(String id) async {
    final index = state.todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final updated = state.todos[index].copyWith(
        isCompleted: !state.todos[index].isCompleted,
      );
      final repo = ref.read(todoRepositoryProvider);
      await repo.updateTodo(updated);
      await loadTodos();
    }
  }

  Future<void> updateTodo(TodoItem item) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.updateTodo(item);
    await loadTodos();
  }

  Future<void> deleteTodo(String id) async {
    final repo = ref.read(todoRepositoryProvider);
    await repo.deleteTodo(id);
    await loadTodos();
  }

  void setFilter(TodoFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final todoProvider = NotifierProvider<TodoNotifier, TodoState>(() {
  return TodoNotifier();
});
