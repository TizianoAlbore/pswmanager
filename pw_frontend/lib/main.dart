import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/dashboard.dart';
import 'pages/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        '/dashboard': (context) => DashboardPage(),
        '/signup': (context) => SignupPage()
      },
    );
  }
}
