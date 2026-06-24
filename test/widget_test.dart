import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidyduu/main.dart';
import 'package:tidyduu/providers/todo_provider.dart';

void main() {
  testWidgets('TidyDuu smoke test', (WidgetTester tester) async {
    // Initialize mock values for SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // Pump the app with mock overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const TidyDuuApp(),
      ),
    );

    // Verify initial widgets and text render correctly
    expect(find.text('TidyDuu'), findsOneWidget);
    expect(find.text('Task Progress'), findsOneWidget);
    expect(find.text('Clear mind, clean slate'), findsOneWidget);
  });
}
