import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pw_frontend/pages/dashboard.dart';
import 'package:pw_frontend/pages/settings.dart';
import 'package:pw_frontend/pages/totp.dart';
import 'package:pw_frontend/utils/psw_holder.dart';

class DrawerWidget extends StatefulWidget {
  final PasswordHolder temporizedPassword;
  const DrawerWidget({super.key, required this.temporizedPassword});

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
            decoration: BoxDecoration(
              color: Color(0xFF00796B), // Same blue as the dashboard header
            ),
            child:Text(
              'Welcome',
              style: TextStyle(
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
              Navigator.pushNamed(context,
                                  '/dashboard',
                                  arguments: DashboardArguments(widget.temporizedPassword));
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
              Navigator.pushNamed(context,
                                  '/totp',
                                  arguments: TotpArguments(widget.temporizedPassword));
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
              Navigator.pushNamed(context,
                                  '/settings',
                                  arguments: SettingsArguments(widget.temporizedPassword));
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
