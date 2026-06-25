# Changelog

All notable changes to TidyDuu will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-06-25

This is the initial stable release of **TidyDuu** prepared for portfolio presentation, showcasing clean architecture patterns, robust state management, and production-quality engineering.

### Added
- **Core Task Management**: 
  - Interactive checklists to create, edit, category-filter, and delete tasks.
  - Interactive subtasks checklist with individual check toggles and overall completion progress bars.
  - Persistent task notes indicator on todo tiles.
  - Recurring tasks support (daily, weekly, monthly options) with auto-creation of successor occurrences upon task completion.
  - Fast task creation via an expanding shorthand Quick Add input bar.
  - Intuitive list swipe gestures: Swipe-to-complete (right) and Swipe-to-delete (left) with immediate RESTORE/undo availability.
- **Organization & Search**:
  - Task categorization using custom tags (*Personal, Work, Study, Errands, Other*).
  - High-performance, case-insensitive keyword search across task titles.
- **Cockpits & Schedulers**:
  - **Today Focus view**: Compilation cockpit displaying tasks due or marked for today, featuring a dynamic progress indicator and motivational headers.
  - **Custom Grid Calendar**: A custom-drawn grid calendar mapping task load concentrations to dates without third-party dependencies.
- **Productivity Analytics (Dashboard)**:
  - Numeric metric cards tracking total, active, completed, overdue, and today's tasks.
  - Circular completion percentage ring and active consecutive task streak tracker.
- **Focus Workstation (Focus Mode)**:
  - Integrated Pomodoro session workspace (25 min focus / 5 min break cycles) connected to a chosen task, showing remaining progress ring, subtask checklists, and finish alerts.
- **Preferences & System Settings**:
  - Material 3 theme preferences (System Adaptive, Light, or Dark Mode).
  - User configuration of default task priorities and reminder timings for new tasks.
  - Built-in notification permission requests and localized storage cleanups.
- **Engineered Backend & Core Quality**:
  - **State Management**: Clean state separation utilizing Riverpod providers for all widgets, timers, and filters.
  - **Offline Storage**: Custom JSON serialization framework over SharedPreferences with backward-compatible model parsing.
  - **Reminders**: Timezone-aware local alarms scheduled precisely via flutter_local_notifications.
  - **CI & Quality Gates**: Stricter static analysis constraints, automated formatting validation, and a pipeline CI in GitHub Actions.
  - **Testing**: A comprehensive test suite with 52 test cases covering unit models, persistence operations, timers, and widget widgets.
  - **Templates**: Structured Bug Report, Feature Request, and Pull Request templates under `.github/`.
  - **Portfolio Setup**: Clean asset structure, launch posts, and a detailed README.
