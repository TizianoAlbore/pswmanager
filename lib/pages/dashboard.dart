import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pw_frontend/utils/psw_holder.dart';
import 'package:pw_frontend/widgets/drawer.dart';
import 'package:pw_frontend/widgets/group_column.dart';
import 'package:pw_frontend/widgets/password_column.dart';
import 'package:pw_frontend/widgets/password_detail.dart';
import '../main.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class DashboardArguments {
  final PasswordHolder temporizedPassword;

  DashboardArguments(this.temporizedPassword);
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _selectedGroupController =
      TextEditingController();
  final TextEditingController _selectedPasswordController =
      TextEditingController();

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

    final args =
        ModalRoute.of(context)?.settings.arguments as DashboardArguments?;
    final PasswordHolder temporizedPassword =
        args?.temporizedPassword ?? PasswordHolder();

    if (temporizedPassword.temporizedMasterPassphrase == null) {
      Future.microtask(() {
        Navigator.pop(context);
        FirebaseAuth.instance.signOut();
        Navigator.pushNamed(context, '/');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
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
      drawer: DrawerWidget(temporizedPassword: temporizedPassword,),
      body: ValueListenableBuilder<ThemeData>(
        valueListenable: currentThemeNotifier,
        builder: (context, theme, child) {
          // Determine the text color based on the selected theme
          final textColor =
              theme.brightness == Brightness.dark ? Colors.white : Colors.black;

          return Container(
            height: 800,
            color: theme
                .scaffoldBackgroundColor, // Dynamically change background color based on theme
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // GroupColumn always visible
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12), // Raggio di arrotondamento
                    color: Colors.black12,
                  ),
                  child: SizedBox(
                    width: 330,
                    height: 450,
                    child: GroupColumnPage(
                      firestore: firestore,
                      userId: userId,
                      selectedGroupController: _selectedGroupController,
                      callback_selectedGroup: callback_selectedGroup,
                      textColor: textColor, // Pass textColor to GroupColumnPage
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // PasswordColumn displayed only if a group is selected
                if (_selectedGroupController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(12), // Raggio di arrotondamento
                      color: Colors.black12,
                    ),
                    child: SizedBox(
                      width: 330,
                      height: 450,
                      child: PasswordColumn(
                        firestore: firestore,
                        userId: userId,
                        selectedGroupText: _selectedGroupController.text,
                        selectedGroupController: _selectedGroupController,
                        selectedPasswordController: _selectedPasswordController,
                        callback_selectedGroup: callback_selectedGroup,
                        callback_selectedPassword: callback_selectedPassword,
                        textColor:
                            textColor, // Pass textColor to PasswordColumn
                        temporizedPassword:
                            temporizedPassword.temporizedMasterPassphrase ?? '',
                      ),
                    ),
                  ),
                const SizedBox(width: 20),

                // PasswordDetail displayed only if a password is selected
                if (_selectedPasswordController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(12), // Raggio di arrotondamento
                      color: Colors.black12,
                    ),
                    child: SizedBox(
                      width: 330,
                      height: 450,
                      child: PasswordDetail(
                        firestore: firestore,
                        userId: userId,
                        selectedGroupController: _selectedGroupController,
                        selectedPasswordController: _selectedPasswordController,
                        updatePasswordList: () {
                          setState(() {});
                        },
                        textColor:
                            textColor, // Pass textColor to PasswordDetail
                        temporizedPassword:
                            temporizedPassword.temporizedMasterPassphrase ?? '',
                      ),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
