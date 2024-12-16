import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pw_frontend/widgets/drawer.dart';
import 'package:pw_frontend/widgets/group_column.dart';
import 'package:pw_frontend/widgets/password_column.dart';
import 'package:pw_frontend/widgets/password_detail.dart';
import '../main.dart';  // Ensure correct import for theme helper

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _selectedGroupController = TextEditingController();
  final TextEditingController _selectedPasswordController = TextEditingController();

  // Callbacks for selected group and password
  callback_selectedGroup(newValue) {
    setState(() {
      _selectedGroupController.text = newValue;
    });
  }

  callback_selectedPassword(newValue) {
    setState(() {
      _selectedPasswordController.text = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? 'Unknown User ID';

    if (user == null) {
      Future.microtask(() {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/');   
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: const DrawerWidget(),
      body: ValueListenableBuilder<ThemeData>(
        valueListenable: currentThemeNotifier,
        builder: (context, theme, child) {
          return Container(
            color: theme.scaffoldBackgroundColor, // Dynamically change background color based on theme
            child: Row(
              children: [
                // GroupColumn always visible
                Expanded(
                  flex: 1,
                  child: GroupColumnPage(
                    firestore: firestore,
                    userId: userId,
                    selectedGroupController: _selectedGroupController,
                    callback_selectedGroup: callback_selectedGroup,
                  ),
                ),

                // PasswordColumn displayed only if a group is selected
                if (_selectedGroupController.text.isNotEmpty)
                  Expanded(
                    flex: 1,
                    child: PasswordColumn(
                      firestore: firestore,
                      userId: userId,
                      selectedGroupController: _selectedGroupController,
                      selectedPasswordController: _selectedPasswordController,
                      callback_selectedGroup: callback_selectedGroup,
                      callback_selectedPassword: callback_selectedPassword,
                    ),
                  ),

                // PasswordDetail displayed only if a password is selected
                if (_selectedPasswordController.text.isNotEmpty)
                  Expanded(
                    flex: 1,
                    child: PasswordDetail(
                      firestore: firestore,
                      userId: userId,
                      selectedGroupController: _selectedGroupController,
                      selectedPasswordController: _selectedPasswordController,
                      updatePasswordList: () {
                        setState(() {});
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
