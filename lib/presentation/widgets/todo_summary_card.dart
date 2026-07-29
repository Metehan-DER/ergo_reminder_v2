import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../core/utils/page_transitions.dart';
import '../pages/todo_page.dart';
import '../providers/todo_provider.dart';

class TodoSummaryCard extends ConsumerWidget {
  const TodoSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final todoState = ref.watch(todoProvider);

    final totalCount = todoState.todos.length;
    final pendingCount = todoState.pendingCount;
    final completedCount = todoState.completedCount;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final todayTodos = todoState.filteredTodos.take(3).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Başlık ve İlerleme Halkası Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // İlerleme Dairesi
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                value: totalCount > 0 ? progress : 0,
                                backgroundColor: Colors.white12,
                                color: Colors.greenAccent,
                                strokeWidth: 4,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.todayTasksSummary,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.pendingTasksCount(pendingCount),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sayfa Geçiş Butonları
                  Row(
                    children: [
                      _buildHeaderIconButton(
                        icon: Icons.task_alt,
                        tooltip: l10n.todoTitle,
                        isPrimary: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            AppPageRoute(child: const TodoPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              if (todayTodos.isNotEmpty) ...[
                const SizedBox(height: 14),
                Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
                const SizedBox(height: 10),
                Column(
                  children: todayTodos.map((todo) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          ref.read(todoProvider.notifier).toggleTodo(todo.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: todo.isCompleted
                                      ? Colors.greenAccent
                                      : Colors.white.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: todo.isCompleted
                                        ? Colors.greenAccent
                                        : Colors.white54,
                                    width: 1.5,
                                  ),
                                ),
                                child: todo.isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        size: 13,
                                        color: Colors.black,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  todo.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: todo.isCompleted
                                        ? Colors.white38
                                        : Colors.white,
                                    fontSize: 13,
                                    fontWeight: todo.isCompleted
                                        ? FontWeight.normal
                                        : FontWeight.w500,
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              if (todo.dueDate != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary
            ? Colors.deepPurpleAccent.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: isPrimary ? Colors.deepPurpleAccent : Colors.white24,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}
