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

  PasswordColumn({super.key, required this.firestore, required this.userId, required this.selectedGroupController, required this.selectedPasswordController, required this.callback_selectedGroup, required this.callback_selectedPassword});

  @override
  State<PasswordColumn> createState() => _PasswordColumnState();
}

class _PasswordColumnState extends State<PasswordColumn> {

  callbackUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser(widget.firestore, widget.userId),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              Text(
                'Group Passwords',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              CircularProgressIndicator(),
            ]
          );
        } else if (snapshot.hasError) {
          return const Column(
            children: [
              Text(
                'Select a group to view passwords',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),     
            ],
          );
        } else {
          Map<String, dynamic> passwords = snapshot.data ?? {};
          Map<String, dynamic> passwordsList = passwords['groups'][widget.selectedGroupController.text] ?? {};
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Group Passwords",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: passwordsList.length + 1,
                  itemBuilder: (context, index) {
                    if(index == passwordsList.length) {
                      return ListTile(
                        trailing: IconButton(
                          icon: const Icon(Icons.add_rounded),
                          color: Colors.green[400],
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomModal(firestore: widget.firestore, userId: widget.userId, callbackUpdate: callbackUpdate,);
                              },
                            );
                          },
                        ),
                      );
                    }
                    return Column(
                    children: [
                      ListTile(
                      title: Text(
                        passwordsList.values.elementAt(index)['title'],
                        style: TextStyle(
                          color: (widget.selectedPasswordController.text == passwordsList.keys.elementAt(index))
                          ? Colors.white
                          : Colors.white70,
                          ),
                        ),
                      onTap: () {
                        setState(() {
                          widget.callback_selectedPassword(passwordsList.keys.elementAt(index));
                        });
                      },
                      selected: widget.selectedPasswordController.text == passwordsList.keys.elementAt(index),
                      selectedTileColor: Colors.grey[850],
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_rounded),
                        color: Colors.red[400],
                        onPressed: () async {
                          try {
                            await deletePassword(passwordsList.keys.elementAt(index), widget.firestore, widget.userId);
                            setState(() {
                                passwordsList.remove(passwordsList.keys.elementAt(index));
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
      }
    );
  }
}