import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/todo_entity.dart';
import '../../l10n/app_localizations.dart';
import '../providers/stats_provider.dart';
import '../providers/todo_provider.dart';
import 'todo_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final todoState = ref.watch(todoProvider);
    final statsAsync = ref.watch(statsProvider);

    final todosForSelectedDate = todoState.todos.where((t) {
      if (t.dueDate == null) return false;
      return _isSameDay(t.dueDate!, _selectedDate);
    }).toList();

    return  SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glassmorphism Calendar Container
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Month Header & Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          DateFormat.yMMMM().format(_focusedMonth),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Days of Week Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'].map((day) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(color: Colors.white24, height: 20),

                    // Days Grid
                    _buildCalendarGrid(todoState.todos),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Selected Day Details Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${DateFormat.yMMMMd().format(_selectedDate)} ${l10n.dailySummary}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TodoPage()),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.addTask),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.lightBlueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Ergonomic Break Stats summary for selected day (if today)
          if (_isSameDay(_selectedDate, DateTime.now()))
            statsAsync.when(
              data: (stats) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStatItem(
                      l10n.todayCompleted,
                      stats.completed.toString(),
                      Icons.check_circle_outline_rounded,
                      Colors.greenAccent,
                    ),
                    _buildMiniStatItem(
                      l10n.todaySnoozed,
                      stats.snoozed.toString(),
                      Icons.snooze_rounded,
                      Colors.amberAccent,
                    ),
                    _buildMiniStatItem(
                      l10n.todayIgnored,
                      stats.ignored.toString(),
                      Icons.history_rounded,
                      Colors.orangeAccent,
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),

          // Scheduled Todos for selected day
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.task_alt_rounded, color: Colors.greenAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${l10n.todoTitle} (${todosForSelectedDate.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (todosForSelectedDate.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            l10n.noTasksFound,
                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todosForSelectedDate.length,
                        itemBuilder: (context, index) {
                          final todo = todosForSelectedDate[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: Checkbox(
                                value: todo.isCompleted,
                                activeColor: Colors.greenAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                onChanged: (val) {
                                  ref.read(todoProvider.notifier).toggleTodo(todo.id);
                                },
                              ),
                              title: Text(
                                todo.title,
                                style: TextStyle(
                                  color: todo.isCompleted ? Colors.white38 : Colors.white,
                                  fontWeight: FontWeight.w500,
                                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              subtitle: todo.dueDate != null
                                  ? Text(
                                      DateFormat('HH:mm').format(todo.dueDate!),
                                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildCalendarGrid(List<TodoItem> allTodos) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    // ISO weekday: Monday is 1, Sunday is 7
    final startingWeekday = firstDayOfMonth.weekday; // 1 to 7

    final List<Widget> dayWidgets = [];

    // Empty spaces before first day
    for (int i = 1; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Days of the month
    final now = DateTime.now();
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isToday = _isSameDay(date, now);
      final isSelected = _isSameDay(date, _selectedDate);

      final dayTodos = allTodos.where((t) => t.dueDate != null && _isSameDay(t.dueDate!, date)).toList();
      final hasTodos = dayTodos.isNotEmpty;
      final hasHighPriority = dayTodos.any((t) => t.priority == TodoPriority.high);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.deepPurpleAccent
                  : isToday
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: isToday && !isSelected
                  ? Border.all(color: Colors.lightBlueAccent, width: 1.8)
                  : Border.all(color: Colors.white12, width: 0.8),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? Colors.lightBlueAccent
                            : Colors.white.withValues(alpha: 0.9),
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (hasTodos)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: hasHighPriority ? Colors.redAccent : Colors.amberAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.1,
      children: dayWidgets,
    );
  }
}
