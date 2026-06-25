import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../providers/settings_provider.dart';
import '../providers/todo_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // We request status or check locally, but standard local notifications plugin does not expose hasPermission directly.
    // We can run requestPermissions silently or assume active if user granted.
  }

  Future<void> _handlePermissionRequest() async {
    final success = await ref
        .read(notificationServiceProvider)
        .requestPermissions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Notification permissions enabled!'
                : 'Notification permissions denied.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showClearCompletedDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.cleaning_services_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Clear Completed'),
            ],
          ),
          content: const Text(
            'Are you sure you want to permanently delete all completed tasks? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).clearCompletedTasks();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Completed tasks cleared successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              const Text('Clear All Tasks'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete ALL tasks (active and completed)? This will completely reset your list and cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).clearAllTasks();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All tasks cleared successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        children: [
          // Section: Appearance
          _buildSectionHeader('Appearance'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Theme Mode',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        icon: Icon(Icons.settings_suggest_rounded),
                        label: Text('System'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Light'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateThemeMode(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor:
                          theme.colorScheme.primaryContainer,
                      selectedForegroundColor:
                          theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Section: Task Defaults
          _buildSectionHeader('Task Defaults'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.priority_high_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Default Priority'),
                  subtitle: Text(
                    'New tasks will start with ${settings.defaultPriority.label} priority',
                  ),
                  trailing: DropdownButton<TodoPriority>(
                    value: settings.defaultPriority,
                    underline: const SizedBox(),
                    items: TodoPriority.values.map((priority) {
                      return DropdownMenuItem<TodoPriority>(
                        value: priority,
                        child: Text(priority.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateDefaultPriority(val);
                      }
                    },
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications_active_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Default Reminder'),
                  subtitle: Text(
                    settings.defaultReminder == TodoReminder.none
                        ? 'No notification scheduled by default'
                        : 'Notification set to: ${settings.defaultReminder.label}',
                  ),
                  trailing: DropdownButton<TodoReminder>(
                    value: settings.defaultReminder,
                    underline: const SizedBox(),
                    items: TodoReminder.values.map((reminder) {
                      return DropdownMenuItem<TodoReminder>(
                        value: reminder,
                        child: Text(reminder.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateDefaultReminder(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Section: Permissions
          _buildSectionHeader('Permissions'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.15),
            child: ListTile(
              leading: Icon(
                Icons.notifications_none_rounded,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Notification Permission'),
              subtitle: const Text('Enable alerts for due times and reminders'),
              trailing: ElevatedButton(
                onPressed: _handlePermissionRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Grant'),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Section: Danger Zone
          _buildSectionHeader('Danger Zone', isDanger: true),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
            ),
            color: theme.colorScheme.errorContainer.withOpacity(0.08),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.cleaning_services_rounded,
                    color: theme.colorScheme.error,
                  ),
                  title: const Text('Clear Completed Tasks'),
                  subtitle: const Text('Remove completed items from storage'),
                  onTap: _showClearCompletedDialog,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.error.withOpacity(0.2),
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_rounded,
                    color: theme.colorScheme.error,
                  ),
                  title: const Text('Clear All Tasks'),
                  subtitle: const Text('Erase all tasks. Complete reset.'),
                  onTap: _showClearAllDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // About App Section
          Center(
            child: Column(
              children: [
                Text(
                  'TidyDuu',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Version 1.0.0+1',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildSectionHeader(String title, {bool isDanger = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isDanger ? theme.colorScheme.error : theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
