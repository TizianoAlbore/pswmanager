import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pw_frontend/utils/totp/totp.dart';
import 'package:pw_frontend/utils/user_utils.dart';
import 'package:pw_frontend/widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pw_frontend/widgets/totp_card.dart';
import 'package:pw_frontend/widgets/totp_modal.dart';

class TotpPage extends StatefulWidget {
  const TotpPage({super.key});

  @override
  State<TotpPage> createState() => _TotpPageState();
}

class _TotpPageState extends State<TotpPage> {
  late Timer _timer;
  late ValueNotifier<int> _remainingTimeNotifier;

  @override
  void initState() {
    super.initState();
    int initialRemainingTime = 30 - (DateTime.now().second % 30);
    _remainingTimeNotifier = ValueNotifier<int>(initialRemainingTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _remainingTimeNotifier.value = (_remainingTimeNotifier.value - 1) % 30;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _remainingTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? 'Unknown User ID';

    return Scaffold(
      appBar: AppBar(
        title: const Text('TOTP Manager'),
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
      body: FutureBuilder(
        future: getUser(firestore, userId),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            Map<String, dynamic> user = snapshot.data ?? {};
            List<String> totpEntries = (user['totps'] ?? {}).keys.toList();
            totpEntries.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddTotpModal(firestore: firestore, userId: userId);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    Map<String, dynamic> totpEntry = user['totps'][totpEntries[index]];  
                    Totp totp = Totp(secret: totpEntry['secret']!.codeUnits,
                                    algorithm: Algorithm.values.firstWhere(
                                      (e) => e.toString().split('.').last == totpEntry['algorithm'],
                                      orElse: () => Algorithm.sha1,
                                    ),
                                    period: totpEntry['period'],
                                    digits: totpEntry['digits'],
                    );
                    return TotpCard(totp: totp,
                                    remainingTimeNotifier: _remainingTimeNotifier,
                                    name: totpEntry['name'],
                                    service: totpEntry['service']);
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}