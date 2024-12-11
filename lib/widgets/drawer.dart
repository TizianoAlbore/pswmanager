import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidget();
}

class _DrawerWidget extends State<DrawerWidget> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF00796B), // Same blue as the dashboard header
            ),
            child:Text(
              'Welcome',
              style: const TextStyle(
                color: Colors.white, // High contrast text for accessibility
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            onTap: () {
              if (ModalRoute.of(context)?.settings?.name == '/dashboard') {
                Navigator.pop(context);
              }else{
              Navigator.pop(context);
              Navigator.pushNamed(context, '/dashboard');
            }
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('TOTP Manager'),
            onTap: () {
              if (ModalRoute.of(context)?.settings?.name == '/totp') {
                Navigator.pop(context);
              }else{
              Navigator.pop(context);
              Navigator.pushNamed(context, '/totp');
            }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              if (ModalRoute.of(context)?.settings?.name == '/settings') {
                Navigator.pop(context);
              }else{
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
