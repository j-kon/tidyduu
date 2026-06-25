import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidyduu/models/todo.dart';
import 'package:tidyduu/providers/todo_provider.dart';
import 'package:tidyduu/services/notification_service.dart';
import 'package:tidyduu/screens/home_screen.dart';
import 'package:tidyduu/screens/settings_screen.dart';

class FakeNotificationService implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermissions() async => true;
  @override
  Future<void> scheduleNotification(Todo todo) async {}
  @override
  Future<void> cancelNotification(String todoId) async {}
  @override
  Future<void> showInstantNotification(String title, String body) async {}
}

void main() {
  late SharedPreferences prefs;
  late FakeNotificationService fakeNotificationService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    fakeNotificationService = FakeNotificationService();
  });

  Widget createWidgetUnderTest({AppTab initialTab = AppTab.tasks}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(fakeNotificationService),
        appTabProvider.overrideWith((ref) => initialTab),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('Quick Add bar adds a task on submit', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(initialTab: AppTab.tasks));
    await tester.pumpAndSettle();

    // Verify Quick Add hint is visible
    expect(find.text('Quick add task...'), findsOneWidget);

    // Enter text and submit
    await tester.enterText(find.byType(TextField).first, 'Quickly Added Task');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Verify task is added to list
    expect(find.text('Quickly Added Task'), findsOneWidget);
  });

  testWidgets('Settings screen options can be toggled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(
            fakeNotificationService,
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Verify theme selector exists
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // Tap dark mode segmented button segment
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    // Verify settings has updated (we can check SharedPrefs value)
    expect(prefs.getString('theme_mode'), 'dark');
  });
}
