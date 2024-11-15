import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ottieni l'utente attualmente autenticato
    final User? user = FirebaseAuth.instance.currentUser;

    // Ottieni userId e userEmail
    final String userId = user?.uid ?? 'Unknown User ID';
    final String userEmail = user?.email ?? 'Unknown Email';

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
          child: Text(
            'Welcome!\n\nUser ID: $userId\nEmail: $userEmail',
            textAlign: TextAlign.center
          ),
        ),
      ),
    );
  }
}

