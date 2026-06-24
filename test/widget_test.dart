import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidyduu/main.dart';
import 'package:tidyduu/providers/todo_provider.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TidyDuuApp(),
    );
  }

  testWidgets('Home screen loads and app title TidyDuu appears', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Title and statistics appear
    expect(find.text('TidyDuu'), findsOneWidget);
    expect(find.text('Task Progress'), findsOneWidget);
    expect(find.text('Clear mind, clean slate'), findsOneWidget);
  });

  testWidgets('Tapping Add Task FAB opens Add Task BottomSheet UI', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find the FAB by its label
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);

    // Tap the FAB to open bottom sheet
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Verify bottom sheet title is visible
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('Task Title'), findsOneWidget);
    expect(find.text('Description (Optional)'), findsOneWidget);
  });

  testWidgets('A valid task can be added through the UI', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Open add task bottom sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter text in title field
    final titleField = find.widgetWithText(TextFormField, 'Task Title');
    expect(titleField, findsOneWidget);
    await tester.enterText(titleField, 'Learn Flutter Testing');
    await tester.pumpAndSettle();

    // Enter text in description field
    final descField = find.widgetWithText(TextFormField, 'Description (Optional)');
    expect(descField, findsOneWidget);
    await tester.enterText(descField, 'Practice widget tests');
    await tester.pumpAndSettle();

    // Tap Create button
    final createBtn = find.text('Create');
    expect(createBtn, findsOneWidget);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    // Verify bottom sheet closed and new task is rendered on screen
    expect(find.text('New Task'), findsNothing);
    expect(find.text('Learn Flutter Testing'), findsOneWidget);
    expect(find.text('Practice widget tests'), findsOneWidget);
  });

  testWidgets('An empty task cannot be added through the UI and validation triggers', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Open add task bottom sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap Create button without entering title
    final createBtn = find.text('Create');
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    // Verify validation error text appears
    expect(find.text('Please enter a title'), findsOneWidget);
    // Verify dialog remains open
    expect(find.text('New Task'), findsOneWidget);

    // Cancel out
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify dialog is closed and task is not added
    expect(find.text('New Task'), findsNothing);
    expect(find.text('Clear mind, clean slate'), findsOneWidget);
  });
}
