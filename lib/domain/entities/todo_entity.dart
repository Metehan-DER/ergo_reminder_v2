enum TodoPriority { low, medium, high }

enum TodoCategory { work, health, ergo, personal }

class TodoItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TodoPriority priority;
  final TodoCategory category;
  final DateTime? dueDate;
  final DateTime createdAt;

  TodoItem({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = TodoPriority.medium,
    this.category = TodoCategory.work,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TodoPriority? priority,
    TodoCategory? category,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'category': category.name,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: TodoPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TodoPriority.medium,
      ),
      category: TodoCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TodoCategory.work,
      ),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
