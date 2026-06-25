import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item_tile.dart';

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
      );
    });
  }

  List<Todo> _getTasksOnDate(DateTime date) {
    final todos = ref.watch(todoListProvider);
    return todos.where((todo) => _isSameDay(todo.dueDate, date)).toList();
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final calendarTodos = ref.watch(calendarTodoListProvider);

    // Calculations for the calendar grid
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    final paddingDays = firstWeekday - 1;
    final totalGridItems = paddingDays + daysInMonth;

    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthStr =
        '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Month Navigation Header
                Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            monthStr,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded),
                                onPressed: () => _changeMonth(-1),
                                tooltip: 'Previous Month',
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded),
                                onPressed: () => _changeMonth(1),
                                tooltip: 'Next Month',
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.05, end: 0),

                // Weekday Headers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekdays.map((day) {
                      return SizedBox(
                        width: 40.0,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 4.0),

                // Calendar Grid
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: totalGridItems,
                        itemBuilder: (context, index) {
                          if (index < paddingDays) {
                            return const SizedBox();
                          }

                          final day = index - paddingDays + 1;
                          final date = DateTime(
                            _currentMonth.year,
                            _currentMonth.month,
                            day,
                          );
                          final isSelected = _isSameDay(date, selectedDate);

                          final now = DateTime.now();
                          final isToday = _isSameDay(
                            date,
                            DateTime(now.year, now.month, now.day),
                          );
                          final dateTodos = _getTasksOnDate(date);

                          return GestureDetector(
                            onTap: () {
                              ref
                                      .read(
                                        calendarSelectedDateProvider.notifier,
                                      )
                                      .state =
                                  date;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? theme.colorScheme.primaryContainer
                                          .withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : isToday
                                      ? theme.colorScheme.primary.withOpacity(
                                          0.3,
                                        )
                                      : theme.colorScheme.outlineVariant
                                            .withOpacity(0.15),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child:
                                        Container(
                                              margin: const EdgeInsets.only(
                                                top: 3.0,
                                                bottom: 2.0,
                                              ),
                                              width: 20.0,
                                              height: 20.0,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '$day',
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          isSelected || isToday
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? theme
                                                                .colorScheme
                                                                .onPrimary
                                                          : isToday
                                                          ? theme
                                                                .colorScheme
                                                                .primary
                                                          : theme
                                                                .colorScheme
                                                                .onSurface,
                                                      fontSize: 11.0,
                                                    ),
                                              ),
                                            )
                                            .animate(
                                              target: isSelected ? 1.0 : 0.0,
                                            )
                                            .scale(
                                              begin: const Offset(0.85, 0.85),
                                              end: const Offset(1.0, 1.0),
                                              duration: 200.ms,
                                              curve: Curves.easeOutBack,
                                            ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          ...dateTodos.take(2).map((todo) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 2.0,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 3.0,
                                                    vertical: 1.0,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: todo.priority
                                                    .containerColor(context)
                                                    .withOpacity(
                                                      todo.isCompleted
                                                          ? 0.35
                                                          : 0.9,
                                                    ),
                                                borderRadius:
                                                    BorderRadius.circular(3.0),
                                              ),
                                              child: Text(
                                                todo.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 7.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: todo.priority
                                                      .onContainerColor(context)
                                                      .withOpacity(
                                                        todo.isCompleted
                                                            ? 0.5
                                                            : 1.0,
                                                      ),
                                                  decoration: todo.isCompleted
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                ),
                                              ),
                                            );
                                          }),
                                          if (dateTodos.length > 2)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 0.5,
                                              ),
                                              child: Text(
                                                '+${dateTodos.length - 2} more',
                                                textAlign: TextAlign.center,
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      fontSize: 7.5,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant
                                                          .withOpacity(0.6),
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 350.ms)
                    .scale(
                      begin: const Offset(0.97, 0.97),
                      curve: Curves.easeOutBack,
                    ),
              ],
            ),
          ),
        ),
        const Divider(height: 12.0, thickness: 1.0),

        // Selected Date Header
        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tasks: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${calendarTodos.length} items',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
            .animate(delay: 150.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: 4.0),

        // Tasks for Selected Date
        Expanded(
          child: calendarTodos.isEmpty
              ? _buildCalendarEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 96.0),
                  itemCount: calendarTodos.length,
                  itemBuilder: (context, index) {
                    final todo = calendarTodos[index];
                    return TodoItemTile(
                      key: ValueKey('calendar_${todo.id}'),
                      todo: todo,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCalendarEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 64.0,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'No tasks for this date',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Tap the button below to schedule a task for this date.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
