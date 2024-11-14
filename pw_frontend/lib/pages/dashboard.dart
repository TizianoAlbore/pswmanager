import 'package:flutter/material.dart';
import './login.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Naviga alla pagina di login rimuovendo tutte le pagine precedenti
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false, // Rimuove tutte le pagine dallo stack
            );
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}