import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../providers/focus_provider.dart';
import '../providers/todo_provider.dart';

class FocusTab extends ConsumerWidget {
  const FocusTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusTimerProvider);
    final todos = ref.watch(todoListProvider);

    // Find the current focused todo if set
    Todo? focusedTodo;
    if (focusState.focusTodoId != null) {
      try {
        focusedTodo = todos.firstWhere(
          (t) => t.id == focusState.focusTodoId && !t.isCompleted,
        );
      } catch (_) {
        // If the task was completed or deleted, reset focus
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(focusTimerProvider.notifier).setFocusTask(null);
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          child: focusedTodo == null
              ? _buildTaskSelectionView(context, ref, todos)
              : _buildFocusTimerView(context, ref, focusState, focusedTodo),
        ),
      ),
    );
  }

  Widget _buildTaskSelectionView(
    BuildContext context,
    WidgetRef ref,
    List<Todo> todos,
  ) {
    final theme = Theme.of(context);
    final activeTodos = todos.where((t) => !t.isCompleted).toList();

    return Padding(
      key: const ValueKey('selection_view'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16.0),
          Icon(
            Icons.center_focus_strong_rounded,
            size: 64.0,
            color: theme.colorScheme.primary,
          ).animate().scale(
            delay: 100.ms,
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Focus Mode',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Select an active task to start a distraction-free Pomodoro session.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32.0),
          Expanded(
            child: activeTodos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.playlist_add_rounded,
                          size: 48.0,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.5,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'No active tasks found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          'Create a task first to start focusing.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: activeTodos.length,
                    itemBuilder: (context, index) {
                      final todo = activeTodos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withOpacity(0.5),
                            ),
                          ),
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.15,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.0),
                            onTap: () {
                              ref
                                  .read(focusTimerProvider.notifier)
                                  .setFocusTask(todo.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: todo.priority.containerColor(
                                        context,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      todo.category.icon,
                                      color: todo.priority.color(context),
                                      size: 20.0,
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          todo.title,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                        ),
                                        if (todo.subtasks.isNotEmpty) ...[
                                          const SizedBox(height: 4.0),
                                          Text(
                                            '${todo.subtasks.where((s) => s.isCompleted).length}/${todo.subtasks.length} subtasks completed',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusTimerView(
    BuildContext context,
    WidgetRef ref,
    FocusTimerState focusState,
    Todo todo,
  ) {
    final theme = Theme.of(context);
    final minutes = (focusState.remainingSeconds / 60).floor();
    final seconds = focusState.remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final progress =
        1.0 - (focusState.remainingSeconds / focusState.durationSeconds);

    final isRunning = focusState.status == FocusTimerStatus.running;

    return SingleChildScrollView(
      key: const ValueKey('timer_view'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  ref.read(focusTimerProvider.notifier).setFocusTask(null);
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Change Task'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Exit Focus Mode',
                onPressed: () {
                  ref.read(focusTimerProvider.notifier).setFocusTask(null);
                },
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Task details card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: todo.priority.containerColor(context),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Icon(
                          todo.category.icon,
                          color: todo.priority.color(context),
                          size: 18.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          todo.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (todo.notes.isNotEmpty) ...[
                    const SizedBox(height: 12.0),
                    Text(
                      todo.notes,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32.0),

          // Circular progress timer
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isRunning)
                  Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (focusState.isBreak
                                          ? Colors.green
                                          : theme.colorScheme.primary)
                                      .withOpacity(0.25),
                              blurRadius: 25.0,
                              spreadRadius: 8.0,
                            ),
                          ],
                        ),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(0.96, 0.96),
                        end: const Offset(1.04, 1.04),
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      ),
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12.0,
                    backgroundColor: theme.colorScheme.surfaceVariant
                        .withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      focusState.isBreak
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 48.0,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                          focusState.isBreak ? 'BREAK TIME' : 'FOCUSING',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: focusState.isBreak
                                ? Colors.green
                                : theme.colorScheme.primary,
                            letterSpacing: 1.5,
                          ),
                        )
                        .animate(target: isRunning ? 1.0 : 0.0)
                        .fadeIn()
                        .shimmer(
                          duration: 1500.ms,
                          color: Colors.purple.shade100,
                        ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),

          // Timer Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Restart / Reset
              IconButton.filledTonal(
                icon: const Icon(Icons.replay_rounded),
                onPressed: () {
                  ref.read(focusTimerProvider.notifier).reset();
                },
                iconSize: 24,
                padding: const EdgeInsets.all(12),
                tooltip: 'Reset Timer',
              ),
              const SizedBox(width: 24.0),
              // Play / Pause
              IconButton.filled(
                icon: Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                onPressed: () {
                  if (isRunning) {
                    ref.read(focusTimerProvider.notifier).pause();
                  } else {
                    ref.read(focusTimerProvider.notifier).start();
                  }
                },
                iconSize: 36,
                padding: const EdgeInsets.all(16),
                tooltip: isRunning ? 'Pause Session' : 'Start Session',
              ),
              const SizedBox(width: 24.0),
              // Skip Session
              IconButton.filledTonal(
                icon: const Icon(Icons.skip_next_rounded),
                onPressed: () {
                  ref.read(focusTimerProvider.notifier).skipSession();
                },
                iconSize: 24,
                padding: const EdgeInsets.all(12),
                tooltip: 'Skip Session',
              ),
            ],
          ),
          const SizedBox(height: 32.0),

          // Interactive Subtasks checklist section
          if (todo.subtasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Subtasks Checklist',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todo.subtasks.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
                itemBuilder: (context, index) {
                  final sub = todo.subtasks[index];
                  return CheckboxListTile(
                    value: sub.isCompleted,
                    onChanged: (val) {
                      ref
                          .read(todoListProvider.notifier)
                          .toggleSubtask(todo.id, sub.id);
                    },
                    title: Text(
                      sub.title,
                      style: TextStyle(
                        decoration: sub.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: sub.isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    activeColor: theme.colorScheme.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24.0),
          ],

          // Task completion action
          ElevatedButton.icon(
            onPressed: () {
              ref.read(todoListProvider.notifier).toggleTodo(todo.id);
              ref.read(focusTimerProvider.notifier).setFocusTask(null);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task completed! Keep up the good work! 🎉'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Complete Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }
}
