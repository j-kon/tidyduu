import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/todo_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize NotificationService
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const TidyDuuApp(),
    ),
  );
}

class TidyDuuApp extends StatelessWidget {
  const TidyDuuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TidyDuu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E5CE6), // Modern indigo
          brightness: Brightness.light,
          primary: const Color(0xFF5E5CE6),
          primaryContainer: const Color(0xFFE5E5FF),
          onPrimaryContainer: const Color(0xFF1C1B70),
          surface: const Color(0xFFFAFAFC),
          onSurface: const Color(0xFF1C1C1E),
          surfaceVariant: const Color(0xFFEFEFF4),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF5E5CE6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E5CE6),
          brightness: Brightness.dark,
          primary: const Color(0xFF7D7AFF),
          primaryContainer: const Color(0xFF2C2C5E),
          onPrimaryContainer: const Color(0xFFE5E5FF),
          surface: const Color(0xFF121214),
          onSurface: const Color(0xFFF2F2F7),
          surfaceVariant: const Color(0xFF1C1C1E),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1C1C1E),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF7D7AFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
      themeMode: ThemeMode.system, // Supports OS light/dark modes
      home: const HomeScreen(),
    );
  }
}
