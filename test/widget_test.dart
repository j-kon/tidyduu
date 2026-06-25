import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidyduu/main.dart';
import 'package:tidyduu/models/todo.dart';
import 'package:tidyduu/providers/todo_provider.dart';
import 'package:tidyduu/services/notification_service.dart';
import 'package:tidyduu/widgets/todo_item_tile.dart';

class FakeNotificationService implements NotificationService {
  final List<Todo> scheduledTodos = [];
  final List<String> cancelledTodoIds = [];
  bool permissionsRequested = false;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermissions() async {
    permissionsRequested = true;
    return true;
  }

  @override
  Future<void> scheduleNotification(Todo todo) async {
    scheduledTodos.add(todo);
  }

  @override
  Future<void> cancelNotification(String todoId) async {
    cancelledTodoIds.add(todoId);
  }

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

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(fakeNotificationService),
        appTabProvider.overrideWith((ref) => AppTab.tasks),
      ],
      child: const TidyDuuApp(),
    );
  }

  testWidgets('Home screen loads and app title TidyDuu appears', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Title and statistics appear
    expect(find.text('TidyDuu'), findsOneWidget);
    expect(find.text('Task Progress'), findsOneWidget);
    expect(find.text('Clear mind, clean slate'), findsOneWidget);
  });

  testWidgets('Tapping Add Task FAB opens Add Task BottomSheet UI', (
    WidgetTester tester,
  ) async {
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

  testWidgets('A valid task can be added through the UI', (
    WidgetTester tester,
  ) async {
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
    final descField = find.widgetWithText(
      TextFormField,
      'Description (Optional)',
    );
    expect(descField, findsOneWidget);
    await tester.enterText(descField, 'Practice widget tests');
    await tester.pumpAndSettle();

    // Tap Create button
    final createBtn = find.text('Create');
    expect(createBtn, findsOneWidget);
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    // Verify bottom sheet closed and new task is rendered on screen
    expect(find.text('New Task'), findsNothing);
    expect(find.text('Learn Flutter Testing'), findsOneWidget);
    expect(find.text('Practice widget tests'), findsOneWidget);
  });

  testWidgets(
    'A task can be added with High priority and Study category through the UI',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open add task bottom sheet
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter text in title field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Task Title'),
        'High Priority Study Task',
      );
      await tester.pumpAndSettle();

      // Select 'Study' category choice chip
      final studyChip = find.descendant(
        of: find.byType(ChoiceChip),
        matching: find.text('Study'),
      );
      expect(studyChip, findsOneWidget);
      await tester.ensureVisible(studyChip);
      await tester.tap(studyChip);
      await tester.pumpAndSettle();

      // Tap 'High' priority segment
      final highSegment = find.descendant(
        of: find.byType(SegmentedButton<TodoPriority>),
        matching: find.text('High'),
      );
      expect(highSegment, findsOneWidget);
      await tester.ensureVisible(highSegment);
      await tester.tap(highSegment);
      await tester.pumpAndSettle();

      // Tap Create button
      final createBtn = find.text('Create');
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      // Verify task tile is rendered on screen with badges
      expect(
        find.descendant(
          of: find.byType(TodoItemTile),
          matching: find.text('High'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(TodoItemTile),
          matching: find.text('Study'),
        ),
        findsOneWidget,
      );
      expect(find.text('High Priority Study Task'), findsOneWidget);
    },
  );

  testWidgets(
    'An empty task cannot be added through the UI and validation triggers',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open add task bottom sheet
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap Create button without entering title
      final createBtn = find.text('Create');
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      // Verify validation error text appears
      expect(find.text('Please enter a title'), findsOneWidget);
      // Verify dialog remains open
      expect(find.text('New Task'), findsOneWidget);

      // Cancel out
      final cancelBtn = find.text('Cancel');
      await tester.ensureVisible(cancelBtn);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Verify dialog is closed and task is not added
      expect(find.text('New Task'), findsNothing);
      expect(find.text('Clear mind, clean slate'), findsOneWidget);
    },
  );

  testWidgets('Tasks can be searched and filtered by category in the UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // 1. Add "Buy Milk" under "Errands"
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Task Title'),
      'Buy Milk',
    );
    final errandsChip = find.descendant(
      of: find.byType(ChoiceChip),
      matching: find.text('Errands'),
    );
    await tester.ensureVisible(errandsChip);
    await tester.tap(errandsChip);
    await tester.pumpAndSettle();
    final createBtn1 = find.text('Create');
    await tester.ensureVisible(createBtn1);
    await tester.tap(createBtn1);
    await tester.pumpAndSettle();

    // 2. Add "Study Flutter" under "Study"
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Task Title'),
      'Study Flutter',
    );
    final studyChip = find.descendant(
      of: find.byType(ChoiceChip),
      matching: find.text('Study'),
    );
    await tester.ensureVisible(studyChip);
    await tester.tap(studyChip);
    await tester.pumpAndSettle();
    final createBtn2 = find.text('Create');
    await tester.ensureVisible(createBtn2);
    await tester.tap(createBtn2);
    await tester.pumpAndSettle();

    // Verify both are present on the Home screen
    expect(find.text('Buy Milk'), findsOneWidget);
    expect(find.text('Study Flutter'), findsOneWidget);

    // 3. Search for "Milk"
    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Search tasks...',
    );
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Milk');
    await tester.pumpAndSettle();

    // Verify "Buy Milk" is present, but "Study Flutter" is filtered out
    expect(find.text('Buy Milk'), findsOneWidget);
    expect(find.text('Study Flutter'), findsNothing);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();
    expect(find.text('Study Flutter'), findsOneWidget);

    // 4. Tap "Study" Category Filter Chip
    final studyFilterChip = find.text('Study').first;
    await tester.tap(studyFilterChip);
    await tester.pumpAndSettle();

    // Verify "Study Flutter" is present, but "Buy Milk" is filtered out
    expect(find.text('Study Flutter'), findsOneWidget);
    expect(find.text('Buy Milk'), findsNothing);
  });

  testWidgets(
    'Navigation to Today and Calendar tabs works and displays correct empty states',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify initial state is on Tasks tab
      expect(find.text('Task Progress'), findsOneWidget);

      // Navigate to Today tab using NavigationBar specifically
      final todayTab = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Today'),
      );
      expect(todayTab, findsOneWidget);
      await tester.tap(todayTab);
      await tester.pumpAndSettle();

      // Verify Today view is shown
      expect(find.text("Today's Focus"), findsOneWidget);
      expect(find.text('Nothing due today'), findsOneWidget);

      // Navigate to Calendar tab using NavigationBar specifically
      final calendarTab = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Calendar'),
      );
      expect(calendarTab, findsOneWidget);
      await tester.tap(calendarTab);
      await tester.pumpAndSettle();

      // Verify Calendar view is shown
      expect(find.text('No tasks for this date'), findsOneWidget);
    },
  );

  testWidgets('Toggling isToday on task tile in Tasks tab syncs to Today tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Add a task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Task Title'),
      'Important Today Task',
    );
    final createBtn = find.text('Create');
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    expect(find.text('Important Today Task'), findsOneWidget);

    // Tap the sun icon/button to toggle isToday
    final todayIconButton = find.byTooltip('Add to Today');
    expect(todayIconButton, findsOneWidget);
    await tester.ensureVisible(todayIconButton);
    await tester.tap(todayIconButton);
    await tester.pumpAndSettle();

    // The tooltip should change to 'Remove from Today'
    expect(find.byTooltip('Remove from Today'), findsOneWidget);

    // Navigate to Today tab and verify the task is present there
    final todayTab = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Today'),
    );
    await tester.tap(todayTab);
    await tester.pumpAndSettle();

    expect(find.text("Today's Focus"), findsOneWidget);
    expect(find.text('Important Today Task'), findsOneWidget);
    expect(find.text('Nothing due today'), findsNothing);
  });

  testWidgets(
    'Adding a task in Calendar view prepopulates the due date with selected date',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Go to Calendar view
      final calendarTab = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Calendar'),
      );
      await tester.tap(calendarTab);
      await tester.pumpAndSettle();

      // Find a day in the calendar grid to tap, say day 20
      final day20Text = find.text('20');
      expect(day20Text, findsWidgets);
      await tester.tap(day20Text.first);
      await tester.pumpAndSettle();

      // Tap Add Task FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify the due date button has the preselected date "20"
      expect(find.textContaining('Due: 20/'), findsOneWidget);

      // Close dialog
      final cancelBtn = find.text('Cancel');
      await tester.ensureVisible(cancelBtn);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'A task can be created with a due date and a reminder, displaying the reminder badge',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open add task bottom sheet
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Task Title'),
        'Reminder Task Title',
      );
      await tester.pumpAndSettle();

      // Tap due date button
      final dueDateButton = find.widgetWithText(
        OutlinedButton,
        'No due date set',
      );
      await tester.ensureVisible(dueDateButton);
      await tester.tap(dueDateButton);
      await tester.pumpAndSettle();

      // Select today's date in picker (tapping OK in the date picker dialog)
      final okBtn = find.text('OK');
      expect(okBtn, findsOneWidget);
      await tester.tap(okBtn);
      await tester.pumpAndSettle();

      // Verify reminder dropdown appears because a due date is now selected
      final reminderDropdown = find.byType(
        DropdownButtonFormField<TodoReminder>,
      );
      expect(reminderDropdown, findsOneWidget);
      await tester.ensureVisible(reminderDropdown);
      await tester.tap(reminderDropdown);
      await tester.pumpAndSettle();

      // Select '1 hour before'
      final reminderOption = find.text('1 hour before').last;
      await tester.tap(reminderOption);
      await tester.pumpAndSettle();

      // Tap Create button
      final createBtn = find.text('Create');
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      // Verify task is added and shows the "1h before" reminder badge on card
      expect(find.text('Reminder Task Title'), findsOneWidget);
      expect(find.text('1h before'), findsOneWidget);
    },
  );
}
