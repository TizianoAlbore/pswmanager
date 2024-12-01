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
    final String userEmail = user?.email ?? 'Unknown Email';

    // Get the temporized passphrase from the arguments
    final String? _temporizedPassphrase = ModalRoute.of(context)?.settings.arguments as String?;

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
          }
        ),
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
            child: const Icon(Icons.add),
          ),
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          FloatingActionButton(onPressed: () {
            showDialog(context: context,
              builder: (BuildContext context) {
                return GroupModal(firestore: firestore, userId: userId); 
              }
            );
          },
          child: const Icon(Icons.folder),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GroupColumnPage(firestore: firestore, userId: userId),
          ),
        ],
      ),
    );
  }
}
