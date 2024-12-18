import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pw_frontend/widgets/modal.dart';
import '../utils/user_utils.dart';

class PasswordColumn extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;
  final TextEditingController selectedGroupController;
  final TextEditingController selectedPasswordController;
  Function callback_selectedGroup;
  Function callback_selectedPassword;
  final Color textColor; // Accept dynamic text color
  final String temporizedPassword;

  PasswordColumn({
    super.key,
    required this.firestore,
    required this.userId,
    required this.selectedGroupController,
    required this.selectedPasswordController,
    required this.callback_selectedGroup,
    required this.callback_selectedPassword,
    required this.textColor, // Pass text color
    required this.temporizedPassword,
  });

  @override
  State<PasswordColumn> createState() => _PasswordColumnState();
}

class _PasswordColumnState extends State<PasswordColumn> {
  callbackUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return FutureBuilder(
      future: getUser(widget.firestore, widget.userId),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: Colors.yellow),
                  SizedBox(width: 8),
                  Text(
                    "Group Passwords",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              CircularProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          return Column(
            children: [
              Text(
                'Select a group to view passwords',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: currentTheme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          );
        } else {
          Map<String, dynamic> passwords = snapshot.data ?? {};
          Map<String, dynamic> passwordsList = passwords['groups'][widget.selectedGroupController.text] ?? {};
          List<String> sortedKeys = passwordsList.keys.toList()..sort();

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: Colors.yellow),
                    SizedBox(width: 8),
                    Text(
                      "Group Passwords",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedKeys.length + 1,
                  itemBuilder: (context, index) {
                    if (index == sortedKeys.length) {
                      return ListTile(
                        trailing: IconButton(
                          icon: const Icon(Icons.add_rounded),
                          color: Colors.green[400],
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomModal(
                                  firestore: widget.firestore,
                                  userId: widget.userId,
                                  callbackUpdate: callbackUpdate,
                                  temporizedPassword: widget.temporizedPassword,
                                );
                              },
                            );
                          },
                        ),
                      );
                    }

                    String key = sortedKeys[index];
                    Map<String, dynamic> passwordData = passwordsList[key];

                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            passwordData['title'],
                            /*style: TextStyle(
                              color: (widget.selectedPasswordController.text == key)
                                  ? Colors.green
                                  : widget.textColor,
                            ),*/
                          ),
                          onTap: () {
                            setState(() {
                              widget.callback_selectedPassword(key);
                            });
                          },
                          selected: widget.selectedPasswordController.text == key,
                          selectedTileColor: currentTheme.colorScheme.surfaceVariant,
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_rounded),
                            color: Colors.red[400],
                            onPressed: () async {
                              try {
                                await deletePassword(key, widget.firestore, widget.userId);
                                setState(() {
                                  passwordsList.remove(key);
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$e'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
