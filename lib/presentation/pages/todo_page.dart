import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/todo_entity.dart';
import '../../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/todo_provider.dart';

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return const Color(/* 0xFFFF5252 */ 0xFFFF5252);
      case TodoPriority.medium:
        return const Color(/* 0xFFFFB74D */ 0xFFFFB74D);
      case TodoPriority.low:
        return const Color(/* 0xFF4DD0E1 */ 0xFF4DD0E1);
    }
  }

  IconData _getCategoryIcon(TodoCategory category) {
    switch (category) {
      case TodoCategory.work:
        return Icons.laptop_mac_rounded;
      case TodoCategory.health:
        return Icons.favorite_rounded;
      case TodoCategory.ergo:
        return Icons.self_improvement_rounded;
      case TodoCategory.personal:
        return Icons.person_rounded;
    }
  }

  String _getCategoryName(TodoCategory category, AppLocalizations l10n) {
    switch (category) {
      case TodoCategory.work:
        return l10n.categoryWork;
      case TodoCategory.health:
        return l10n.categoryHealth;
      case TodoCategory.ergo:
        return l10n.categoryErgo;
      case TodoCategory.personal:
        return l10n.categoryPersonal;
    }
  }

  String _getPriorityName(TodoPriority priority, AppLocalizations l10n) {
    switch (priority) {
      case TodoPriority.high:
        return l10n.priorityHigh;
      case TodoPriority.medium:
        return l10n.priorityMedium;
      case TodoPriority.low:
        return l10n.priorityLow;
    }
  }

  void _showAddEditTodoSheet([TodoItem? todoToEdit]) {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController(text: todoToEdit?.title ?? '');
    final descController = TextEditingController(text: todoToEdit?.description ?? '');
    TodoPriority selectedPriority = todoToEdit?.priority ?? TodoPriority.medium;
    TodoCategory selectedCategory = todoToEdit?.category ?? TodoCategory.work;
    DateTime? selectedDueDate = todoToEdit?.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: bottomPadding + 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade900.withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: Colors.white24, width: 1.2),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Form Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              todoToEdit == null ? Icons.add_task_rounded : Icons.edit_note_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            todoToEdit == null ? l10n.addTask : l10n.editTask,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title Field
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: l10n.taskTitleHint,
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description Field
                      TextField(
                        controller: descController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: l10n.taskDescHint,
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Priority Selection
                      Text(
                        l10n.priority,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: TodoPriority.values.map((p) {
                          final isSelected = selectedPriority == p;
                          final color = _getPriorityColor(p);
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => setSheetState(() => selectedPriority = p),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? color : Colors.white12,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getPriorityName(p, l10n),
                                      style: TextStyle(
                                        color: isSelected ? color : Colors.white70,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Category Selection
                      Text(
                        l10n.category,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: TodoCategory.values.map((c) {
                          final isSelected = selectedCategory == c;
                          return GestureDetector(
                            onTap: () => setSheetState(() => selectedCategory = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.deepPurpleAccent.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? Colors.deepPurpleAccent : Colors.white12,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(c),
                                    size: 15,
                                    color: isSelected ? Colors.white : Colors.white70,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getCategoryName(c, l10n),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Date & Time Picker Container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.event_rounded, color: Colors.blueAccent, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.dueDate,
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                  Text(
                                    selectedDueDate != null
                                        ? DateFormat('dd MMM yyyy - HH:mm').format(selectedDueDate!)
                                        : l10n.noDueDate,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDueDate ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                                );
                                if (date != null && context.mounted) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: selectedDueDate != null
                                        ? TimeOfDay.fromDateTime(selectedDueDate!)
                                        : const TimeOfDay(hour: 12, minute: 0),
                                  );
                                  if (time != null) {
                                    setSheetState(() {
                                      selectedDueDate = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    });
                                  }
                                }
                              },
                              icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                              label: Text(l10n.calendarSelectDate),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.lightBlueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          onPressed: () {
                            final title = titleController.text.trim();
                            if (title.isEmpty) return;

                            if (todoToEdit == null) {
                              final newTodo = TodoItem(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: title,
                                description: descController.text.trim(),
                                priority: selectedPriority,
                                category: selectedCategory,
                                dueDate: selectedDueDate,
                              );
                              ref.read(todoProvider.notifier).addTodo(newTodo);
                            } else {
                              final updatedTodo = todoToEdit.copyWith(
                                title: title,
                                description: descController.text.trim(),
                                priority: selectedPriority,
                                category: selectedCategory,
                                dueDate: selectedDueDate,
                              );
                              ref.read(todoProvider.notifier).updateTodo(updatedTodo);
                            }
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            l10n.save,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = ref.watch(themeProvider);
    final todoState = ref.watch(todoProvider);
    final bgColors = themeState.activeGradientColors;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.todoTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task, color: Colors.white),
            onPressed: () => _showAddEditTodoSheet(),
            tooltip: l10n.addTask,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 6,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.addTask, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditTodoSheet(),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Metric Stats Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildStatCard(l10n.filterAll, '${todoState.todos.length}', Colors.deepPurpleAccent),
                    const SizedBox(width: 8),
                    _buildStatCard(l10n.filterToday, '${todoState.todayCount}', Colors.blueAccent),
                    const SizedBox(width: 8),
                    _buildStatCard(l10n.filterPending, '${todoState.pendingCount}', Colors.amberAccent),
                    const SizedBox(width: 8),
                    _buildStatCard(l10n.filterCompleted, '${todoState.completedCount}', Colors.greenAccent),
                  ],
                ),
              ),

              // Search & Filter Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          // Search Input
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              ref.read(todoProvider.notifier).setSearchQuery(val);
                            },
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: l10n.searchTasks,
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white60, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, color: Colors.white60, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref.read(todoProvider.notifier).setSearchQuery('');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.15),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Filter Segment Pills
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterPill(l10n.filterAll, TodoFilter.all),
                                _buildFilterPill(l10n.filterToday, TodoFilter.today),
                                _buildFilterPill(l10n.filterPending, TodoFilter.pending),
                                _buildFilterPill(l10n.filterCompleted, TodoFilter.completed),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Todo Items List
              Expanded(
                child: todoState.filteredTodos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.assignment_turned_in_rounded, size: 48, color: Colors.white38),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noTasksFound,
                              style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: todoState.filteredTodos.length,
                        itemBuilder: (context, index) {
                          final todo = todoState.filteredTodos[index];
                          return _buildEnhancedTodoCard(todo, l10n);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, TodoFilter filter) {
    final todoState = ref.watch(todoProvider);
    final isSelected = todoState.filter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          ref.read(todoProvider.notifier).setFilter(filter);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurpleAccent : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.deepPurpleAccent : Colors.white12,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTodoCard(TodoItem todo, AppLocalizations l10n) {
    final priorityColor = _getPriorityColor(todo.priority);
    final categoryIcon = _getCategoryIcon(todo.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: todo.isCompleted ? 0.08 : 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: todo.isCompleted ? Colors.white10 : priorityColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          if (!todo.isCompleted)
            BoxShadow(
              color: priorityColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Priority Color Left Accent Line
              Container(
                width: 5,
                color: todo.isCompleted ? Colors.white24 : priorityColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated Checkbox Button
                      GestureDetector(
                        onTap: () {
                          ref.read(todoProvider.notifier).toggleTodo(todo.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(top: 2),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: todo.isCompleted ? Colors.greenAccent : Colors.white.withValues(alpha: 0.1),
                            border: Border.all(
                              color: todo.isCompleted ? Colors.greenAccent : Colors.white54,
                              width: 1.8,
                            ),
                          ),
                          child: todo.isCompleted
                              ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content Body
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo.title,
                              style: TextStyle(
                                color: todo.isCompleted ? Colors.white38 : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (todo.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                todo.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: todo.isCompleted ? Colors.white38 : Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Category Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(categoryIcon, size: 13, color: Colors.white70),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getCategoryName(todo.category, l10n),
                                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Priority Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: priorityColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: priorityColor, width: 0.8),
                                  ),
                                  child: Text(
                                    _getPriorityName(todo.priority, l10n),
                                    style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),

                                if (todo.dueDate != null) ...[
                                  const Spacer(),
                                  Icon(Icons.schedule_rounded, size: 13, color: Colors.white60),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd MMM HH:mm').format(todo.dueDate!),
                                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Edit / Delete Action Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.white60, size: 18),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () => _showAddEditTodoSheet(todo),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ref.read(todoProvider.notifier).deleteTodo(todo.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
