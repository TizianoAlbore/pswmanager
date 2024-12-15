import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/dashboard.dart';
import 'pages/settings.dart';
import 'pages/totp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    throw Exception('Error loading .env file: $e');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load the selected theme from SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String themePreference = prefs.getString('theme') ?? 'dark'; // Default theme

  runApp(MyApp(selectedTheme: themePreference));
}

class MyApp extends StatelessWidget {
  final String selectedTheme;
  const MyApp({required this.selectedTheme, super.key});

  @override
  Widget build(BuildContext context) {
    // Apply the selected theme
    ThemeData themeData;
    switch (selectedTheme) {
      case 'light':
        themeData = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.light,
            seedColor: const Color(0xFF00796B),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        );
        break;

      case 'colorblind':
        themeData = ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFE6F5F1), // Teal tint
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.light,
            seedColor: const Color(0xFF00796B),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        );
        break;

      default: // Dark theme
        themeData = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1A1818),
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: const Color(0xFF00796B),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        );
        break;
    }

    return MaterialApp(
      title: 'Password Manager',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/settings': (context) => const SettingsPage(),
        '/totp': (context) => const TotpPage(),
      },
      theme: themeData,
    );
  }
}
