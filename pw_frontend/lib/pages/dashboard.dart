import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pw_frontend/utils/user_utils.dart';
import 'package:pw_frontend/utils/password_utils.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Ottieni l'utente attualmente autenticato
    final User? user = FirebaseAuth.instance.currentUser;

    // Ottieni userId e userEmail
    final String userId = user?.uid ?? 'Unknown User ID';
    final String userEmail = user?.email ?? 'Unknown Email';

    final TextEditingController titleController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [Text(
              'Welcome!\n\nUser ID: $userId\nEmail: $userEmail',
              textAlign: TextAlign.center
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => passwordController.text = generateRandomPassword(16),
                ),
              ),
              obscureText: true,
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
           TextButton(
            onPressed: () async {
              try {
              await addPassword(titleController.text, usernameController.text, passwordController.text, noteController.text, firestore, userId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password added successfully')),
              );
              titleController.clear();
              passwordController.clear();
              noteController.clear();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add password: ${e.toString()}')),
                );
              }
            },
            child: const Text('Aggiungi Password'),

          ),
          ],
          ),
        ),
      ),
    );
  }
}

