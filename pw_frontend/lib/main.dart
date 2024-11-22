import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './pages/login.dart';
import './pages/signup.dart';
import '../pages/dashboard.dart';

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
      },
    );
  }
}
