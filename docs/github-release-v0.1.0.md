# 📦 Release v0.1.0 Stable Candidate

Welcome to the first stable release of **TidyDuu** (`v0.1.0`)! 💜

TidyDuu is a premium, distraction-free task coordinator and Pomodoro focus cockpit. It is built as a portfolio-ready mobile app demonstrating code quality, architecture patterns, and native OS integrations in Flutter.

---

## ✨ Release Highlights

*   **📊 Productivity Cockpit (Dashboard)**: Metric cards analyzing total, active, completed, overdue, and today's tasks alongside consecutive task streaks and completion rate indicators.
*   **⏱️ Focus Pomodoro Timer**: Dedicated Pomodoro workspace (25 min focus / 5 min break cycles) linked directly to a chosen task, containing subtask checklists and completion alarms.
*   **📅 Custom Drawn Calendar**: A bespoke date grid mapping task loads to calendar dates without using heavy third-party calendar packages.
*   **🔔 Timezone-Adaptive Reminders**: Pre-scheduled task alarms (at due time, 10m, 1h, 1d before) powered by `flutter_local_notifications` respecting device timezone configurations.
*   **🔄 Recurring & Subtask Checklists**: Shift dates automatically on completion for daily, weekly, or monthly tasks, and manage subtask completion bars.
*   **🌓 Adaptive Material 3 Styling**: Light, dark, and system-adaptive themes with custom curved containers and fluid staggered animations.
*   **👉 Gesture Workflows**: Swipe right to complete, swipe left to delete with a secure "Undo" snackbar. 

---

## 🛠️ Tech Stack & Architecture

*   **Framework**: Flutter 3.x (Stable)
*   **Language**: Dart 3.x
*   **State Management**: Riverpod 2.x (Thin, decoupled controllers)
*   **Persistence**: SharedPreferences (JSON serializer with backward compatibility parsing)
*   **Animations**: Flutter Animate
*   **Architecture**: Feature-first layer separation (`models`, `providers`, `services`, `screens`, `widgets`) maintaining thin view components.

---

## 🧪 Quality & Verification Checks

Before freezing this release, the codebase passed all quality assurance gates:
*   **Code Formatting**: `dart format .` verified with zero format changes.
*   **Static Analysis**: `flutter analyze` completed with **No issues found!** under strict analysis rules.
*   **Automated Tests**: `flutter test` executed and verified all **52 unit/widget tests passed**.
*   **CI Pipeline**: Configured GitHub Actions (`ci.yml`) checking build steps on pushes and pull requests.

---

## ⚠️ Known Limitations
*   **Local Storage Only**: Current tasks are stored locally on the device. Deleting app data or uninstalling the app will clear tasks.
*   **Exact Alarm Approvals**: Exact notifications require permission settings on Android 13+. If permissions are denied, reminders will fire close to but not precisely at the due time.

---

## 🔮 Future Roadmap
*   Cloud Synchronization (Supabase / Firebase Firestore)
*   User accounts and OAuth sign-in
*   Multi-device backup
*   AI task prioritization assistance
*   App Store & Google Play Store release submissions
