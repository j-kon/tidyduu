# 🚀 TidyDuu Launch Post Drafts

This document contains pre-written, highly engaging launch posts tailored for different platforms to promote **TidyDuu** on social media and dev networks.

---

## 💼 LinkedIn Post

**Tone**: Professional, engineering-focused, structured.

```text
🚀 I am excited to share a project I have been developing: TidyDuu — a premium, production-ready Material 3 task manager and Pomodoro productivity app built with Flutter and Dart! 💜

As a mobile developer, my goal was to build a local-first application that showcases modern, production-grade Flutter patterns rather than just another simple TODO list.

Here is a look at what went into the engineering of TidyDuu:

🎨 Premium UX & Design System: Adapted Material 3 adaptive color schemas with custom curved container controls, fluid spring physics, and micro-interactions built using flutter_animate.
⚡ Riverpod State Management: Implemented a robust provider architecture, ensuring clean state isolation and keeping our widgets thin, declarative, and highly responsive.
💾 Safe Offline-First Persistence: Constructed a custom JSON serialization layer on top of SharedPreferences with backward-compatible model factories to prevent crashes on schema upgrades.
⏰ Timezone-Aware Scheduling: Configured native iOS/Android exact alarm channels (via flutter_local_notifications) targeting custom date offsets and recurring intervals.
📅 Custom Elements: Drew a bespoke task calendar grid from scratch to keep packages lean and prevent library version locks.
🧪 Zero Regression Quality Gates: Implemented 52 test cases spanning unit models, state provider behaviors, and interactive widget tests running under strict lints in our CI pipeline.

TidyDuu represents my dedication to high-quality code hygiene, robust architecture, and mobile engineering best practices.

Check out the repository here: https://github.com/j-kon/tidyduu

I’d love to hear your feedback on the architecture, features, or design system! 👇

#Flutter #Dart #MobileDevelopment #CleanArchitecture #StateManagement #CI #AppDev #SoftwareEngineering #OpenSource
```

---

## 🐦 X / Twitter Post

**Tone**: Punchy, visual, hype-centric.

```text
Build, focus, and repeat. 💜

Introducing TidyDuu — a premium Material 3 task manager and Pomodoro workspace built with #Flutter and #Dart!

📊 Interactive Dashboard Insights & Streaks
⏱️ In-App Pomodoro Timer with subtask checklist
📅 Custom Grid Calendar
🔔 Timezone-aware local reminders
🌓 OS-adaptive Dark Mode
🧪 52 tests verifying clean architecture

Built local-first with Riverpod and SharedPreferences.

Full source code & setup guide on GitHub:
👉 https://github.com/j-kon/tidyduu

#BuildInPublic #MobileDev #Dart #FlutterDev #Developer #IndieDev
```

---

## 👾 Discord Developer Community Post

**Tone**: Tech-savvy, conversational, community-friendly.

```text
Hey everyone! 👋 

I just finished building and open-sourcing a premium task coordinator app called **TidyDuu** built with Flutter & Dart, and I’d love for you guys to check out the repo!

GitHub Link: https://github.com/j-kon/tidyduu

**Here is the tech stack & architecture:**
*   **State Management**: Riverpod 2.x (Notifier & StateProvider combinations)
*   **Persistence**: SharedPreferences (custom serialization with upgrade fallback mapping)
*   **Notifications**: Timezone-aware alerts via flutter_local_notifications
*   **UI/UX**: Material 3, custom navigation shell, and micro-animations via flutter_animate
*   **Quality**: 52 automated tests (unit + widget) running on a GitHub Actions CI pipeline with strict analysis rules.

**Cool parts of the codebase:**
1.  **Custom Grid Calendar**: Didn't want package bloat or version conflicts, so I built the calendar grid view from scratch using custom list calculations.
2.  **Robust Storage Migration**: The models have factory constructors that handle parsing older JSON storage models gracefully, defaulting missing keys rather than crashing.
3.  **Pomodoro Task Bindings**: You can bind a specific task to your Pomodoro workspace, complete subtasks on the fly, and receive local alerts when sessions end.

Feel free to clone it, run it, review the code, or drop a PR if you see areas for improvement! 🚀
```

---

## 💬 WhatsApp Status / Short Share

**Tone**: Simple, direct, friendly.

```text
Hey friends! I just finished building TidyDuu, a premium Material 3 task manager & Pomodoro app built with Flutter. Check out the project on GitHub: https://github.com/j-kon/tidyduu 💜🚀
```
