import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'dashboard.dart'; // Imported the dashboard file
=======
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
>>>>>>> 3800764763dafe12f9e9e5054dabe6e50067955b

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
<<<<<<< HEAD
      title: 'Password Manager Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PasswordManagerDashboard(), // Set the dashboard as the home page
      debugShowCheckedModeBanner: false,
=======
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
>>>>>>> 3800764763dafe12f9e9e5054dabe6e50067955b
    );
  }
}
