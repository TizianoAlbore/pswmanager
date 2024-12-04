import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/user_utils.dart';

class PasswordDetail extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;
  final TextEditingController selectedGroupController;
  final TextEditingController selectedPasswordController;

  const PasswordDetail({Key? key, required this.firestore, required this.userId, required this.selectedGroupController, required this.selectedPasswordController}) : super(key: key);
  @override
  State<PasswordDetail> createState() => _PasswordDetailState();
}

class _PasswordDetailState extends State<PasswordDetail> {
  bool isReadOnly = true;

  _toggleReadOnly() {
    setState(() {
      isReadOnly = !isReadOnly;
    });
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
                'Password Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              CircularProgressIndicator(),
            ]
          );
        } else if (snapshot.hasError) {
          return const Column(
            children: [
              Text(
                'Password Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('Select a password to view details'),
            ]
          );
        } else {
          Map<String, dynamic> passwords = snapshot.data ?? {};
          if (  widget.selectedPasswordController.text.isEmpty ||
                widget.selectedGroupController.text.isEmpty ||
                passwords.isEmpty ||
                passwords['groups'][widget.selectedGroupController.text] == null ||
                passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] == null) {
            return const Column(
              children: [
                Text(
                  'Password Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('No password details available'),
              ],
            );
          }
          passwords = passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] ?? {};
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Passwords Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: passwords.length,
                  itemBuilder: (context, index) {
                    String key = passwords.keys.elementAt(index);
                    String value = passwords[key];
                    TextEditingController fieldController = TextEditingController(text: value);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            margin: EdgeInsets.zero,
                            color: Theme.of(context).secondaryHeaderColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                readOnly: isReadOnly,
                                decoration: InputDecoration(
                                  labelText: key,
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () async {
                                          await Clipboard.setData(ClipboardData(text: fieldController.text));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Copied to clipboard'),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(isReadOnly ? Icons.edit : Icons.save),
                                        onPressed: () {
                                          setState(() {
                                            _toggleReadOnly();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                controller: fieldController,
                              ),
                            ),
                          ),
                        ],
                      ),
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