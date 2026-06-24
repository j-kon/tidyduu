# TidyDuu 💜

A premium, sleek, and production-ready Material 3 task management application built with Flutter. TidyDuu blends clean aesthetics, modern state management, and local productivity features into a highly responsive, distraction-free todo experience for both iOS and Android.

---

## ✨ Features

- **📂 Smart Categories**: Organise tasks into *Work, Study, Personal, Errands,* or *Other*.
- **⚡ Priority Levels**: Set *Low, Medium,* or *High* priority for each task, with automatic sorting ensuring urgent items remain at the top.
- **📅 Due Dates & Calendar**: Select due dates with a native picker and view tasks on a bespoke custom grid calendar screen.
- **☀️ Today Focus View**: A dedicated focus view showcasing only today's tasks with an interactive progress indicator.
- **🔔 Local Notifications**: Receive task reminders (At due time, 10m, 1h, or 1d before) using local notifications.
- **🔍 Quick Search**: Search tasks by title dynamically in combination with category or completion filters.
- **🌓 Adaptive Theme**: Support for OS-level Light and Dark modes utilizing Material 3 design tokens.
- **💾 Offline-First**: Reliable persistence using local `SharedPreferences` with custom serialization and backward-compatible fallbacks.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev) (StateNotifier, StateProvider)
- **Local Storage**: [SharedPreferences](https://pub.dev/packages/shared_preferences)
- **Local Notifications**: [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- **Timezones**: [Timezone](https://pub.dev/packages/timezone)
- **Design System**: Material 3 (with custom brand palettes)

---

## 📁 Codebase Architecture

The project adheres to a clean, scalable folder structure designed to separate data, state, services, and UI:

```text
lib/
├── main.dart                 # App Entry Point & Dependency Overrides
├── models/
│   └── todo.dart             # Todo Model & Enums Extensions (Icons, Colors, Labels)
├── providers/
│   └── todo_provider.dart    # Riverpod State Notifiers and Filtered Selectors
├── theme/
│   └── app_theme.dart        # Centralized Light and Dark Material 3 Themes
├── services/
│   ├── storage_service.dart  # Local JSON Persistence Wrapper
│   └── notification_service.dart # Platform Local Notifications Manager
├── screens/
│   ├── home_screen.dart      # Shell Navigator (Bottom Navigation Bar & FAB)
│   ├── tasks_tab.dart        # All Tasks Tab (Filters, Search, Progress)
│   ├── today_tab.dart        # Today Focus Tab (Progress, Sun Empty State)
│   └── calendar_tab.dart     # Custom Grid Calendar Tab
└── widgets/
    ├── add_edit_dialog.dart  # Task Creation & Modification Dialog Sheet
    ├── empty_state.dart      # Standardized Custom Empty States
    ├── filter_chips.dart     # Modular Filter & Category Selection Chips
    └── todo_item_tile.dart   # Polished Modern Task Card Widget (Semantic a11y)
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the Flutter SDK installed on your system.

```bash
flutter --version
```

### Installation

1. Clone the repository.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

- **Start connected emulators/simulators** (e.g., Android emulator or iOS simulator).
- **Run on a specific device**:
  ```bash
  flutter run -d <device-id>
  ```
- **Run on all devices**:
  ```bash
  flutter run -d all
  ```

---

## 🧪 Testing & Verification

TidyDuu has a comprehensive test suite covering models, persistence layers, providers, and widget interactions.

### Run Static Analysis
Ensure code compiles cleanly with zero warnings or lint errors:
```bash
flutter analyze
```

### Run All Unit and Widget Tests
Execute tests and verify correctness:
```bash
flutter test
```

### Format Code
Check code compliance with standard Dart formatting rules:
```bash
dart format .
```

---

## 🔮 Future Improvements

- **☁️ Cloud Sync**: Integrate Firebase/Firestore or PostgreSQL for cross-device synchronization.
- **🔄 Recurring Tasks**: Support daily, weekly, or monthly repeating chores.
- **🏷️ Custom Categories**: Allow users to create custom categories with custom icons and color schemes.
- **📊 Productivity Analytics**: Introduce charts displaying task completion history and streak counts.
