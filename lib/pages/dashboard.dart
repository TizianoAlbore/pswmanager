import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pw_frontend/widgets/modal.dart';
import 'package:pw_frontend/widgets/drawer.dart';

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

    // Ottieni la password temporanea passata come argomento
    final String? _temporizedPassphrase = ModalRoute.of(context)?.settings.arguments as String?;

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
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
      ),
      drawer: DrawerWidget(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Welcome!\n\nUser ID: $userId\nEmail: $userEmail\nTemporary Password: ${_temporizedPassphrase ?? 'No Temporary Password'}',
                textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomModal(
                      firestore: firestore,
                      userId: userId,
                    );
                  },
                );
              },
              child: const Text('Add New Entry'),
            ),
            ],
          ),
        ),
      ),
    );
  }
}