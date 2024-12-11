import 'package:flutter/material.dart';
import 'package:pw_frontend/utils/user_utils.dart';
import 'package:pw_frontend/widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TotpPage extends StatefulWidget {
  const TotpPage({super.key});

  @override
  State<TotpPage> createState() => _TotpPageState();
}

class _TotpPageState extends State<TotpPage> {

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? 'Unknown User ID';

    return Scaffold(
      appBar: AppBar(
        title: const Text('TOTP Manager'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1976D2), // Accessible blue
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
      body: FutureBuilder(
      future: getTotp(firestore, userId),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot){
        if (snapshot.connectionState == ConnectionState.waiting){
          return const CircularProgressIndicator();
        }else if(snapshot.hasError){
          return Text('Error: ${snapshot.error}');
        }else{
          List<String> totpEntries = snapshot.data ?? [];
          totpEntries.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())); 
          return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              ),
            itemCount: totpEntries.length + 1,
            itemBuilder: (context, index) {
              if (index == totpEntries.length) {
                return Card(
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // Handle adding a new TOTP entry
                      },
                    ),
                  ),
                );
              } else {
                return Card(
                  child: Center(
                    child: Text(totpEntries[index]),
                  ),
                );
              }
            },
          ),
        );
        }
      })
    );
  }
}