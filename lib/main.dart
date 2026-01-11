import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

// 1. Global Theme Controller (Accessible from any screen)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FyndoApp());
}

class FyndoApp extends StatelessWidget {
  const FyndoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Wrap MaterialApp with ValueListenableBuilder to listen for theme changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'FYNDO',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // Light Theme Setup
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.light,
            ),
            cardTheme: const CardThemeData(
              elevation: 2,
              margin: EdgeInsets.all(8),
              color: Colors.white,
            ),
          ),

          // Dark Theme Setup
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.dark,
            ),
            cardTheme: const CardThemeData(
              elevation: 2,
              margin: EdgeInsets.all(8),
              color: Color(0xFF1E1E2D), // Deep Dark Grey
            ),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}
