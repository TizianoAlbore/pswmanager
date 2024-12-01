import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _temporizedPassphrase;
  Timer? _passwordTimer;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _temporizedPassphrase = _passwordController.text.trim();

      _passwordTimer?.cancel();
      _passwordTimer = Timer(const Duration(seconds: 10), () {
        _temporizedPassphrase = null;
      });
      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
        arguments: _temporizedPassphrase,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SizedBox(
          width: 300, // Riduce la larghezza del form
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0), // Riduce il padding
            child: Column(
              mainAxisSize: MainAxisSize.min, // Minimizza lo spazio occupato
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20), // Spazio sotto il testo
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10), // Spazio più piccolo tra i campi
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 20), // Spazio
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                SizedBox(height: 20), // Spazio
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Don\'t have an account? Sign up'),
                ),
                SizedBox(height: 50), // Spazio
              ],
            ),
          ),
        ),
      ),
    );
  }
}
