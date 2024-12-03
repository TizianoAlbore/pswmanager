import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pw_frontend/widgets/group_modal.dart';
import 'package:pw_frontend/widgets/modal.dart';
import 'package:pw_frontend/widgets/drawer.dart';
import 'package:pw_frontend/widgets/group_column.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? 'Unknown User ID';

    // Color Palette (colorblind-friendly)
    final Color primaryColor = Color(0xFF0066CC);  // Blue
    final Color secondaryColor = Color(0xFF33CC99);  // Green
    final Color backgroundColor = Color(0xFFF1F5F8);  // Light Gray
    final Color buttonColor = Color(0xFF00B0FF);  // Light Blue
    final Color accentColor = Color(0xFFFFB74D);  // Amber

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        backgroundColor: primaryColor, // Blue color for the app bar
      ),
      drawer: const DrawerWidget(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
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
            backgroundColor: buttonColor,
            child: const Icon(Icons.add),
          ),
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return GroupModal(firestore: firestore, userId: userId);
                },
              );
            },
            backgroundColor: accentColor,
            child: const Icon(Icons.folder),
          ),
        ],
      ),
      body: Container(
        color: backgroundColor, // Light gray background for the body
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: GroupColumnPage(firestore: firestore, userId: userId),
            ),
          ],
        ),
      ),
    );
  }
}
