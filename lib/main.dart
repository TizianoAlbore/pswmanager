import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00796B),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8.0, vertical: 8.0),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A1818), // Dark background
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF00796B) // Accessible color palette
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white, // Text color for high contrast
          ),
          bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white70, // Lighter text for readability
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF00796B), // Teal button for accessibility
          textTheme: ButtonTextTheme.primary,
        ),
      ),
    );
  }
}
