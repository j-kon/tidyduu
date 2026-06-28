import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../widgets/add_edit_dialog.dart';
import 'calendar_tab.dart';
import 'dashboard_tab.dart';
import 'focus_tab.dart';
import 'tasks_tab.dart';
import 'my_day_tab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeTab = ref.watch(appTabProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.0, 0.03),
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
          child: _buildBody(activeTab),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.7),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.35),
                  width: 1.0,
                ),
              ),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: activeTab.index,
              onDestinationSelected: (index) {
                ref.read(appTabProvider.notifier).state = AppTab.values[index];
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.playlist_add_check_outlined),
                  selectedIcon: Icon(Icons.playlist_add_check_rounded),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.wb_sunny_outlined),
                  selectedIcon: Icon(Icons.wb_sunny_rounded),
                  label: 'My Day',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.timer_outlined),
                  selectedIcon: Icon(Icons.timer_rounded),
                  label: 'Focus',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: activeTab == AppTab.focus
          ? null // No FAB in Focus Mode to maintain distraction-free design
          : FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddEditDialog(),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Task',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildBody(AppTab activeTab) {
    switch (activeTab) {
      case AppTab.dashboard:
        return const DashboardTab(key: ValueKey('dashboard_tab'));
      case AppTab.tasks:
        return const TasksTab(key: ValueKey('tasks_tab'));
      case AppTab.myDay:
        return const MyDayTab(key: ValueKey('my_day_tab'));
      case AppTab.calendar:
        return const CalendarTab(key: ValueKey('calendar_tab'));
      case AppTab.focus:
        return const FocusTab(key: ValueKey('focus_tab'));
    }
  }
}
