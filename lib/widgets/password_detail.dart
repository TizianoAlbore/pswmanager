import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pw_frontend/utils/encrypt/aes.dart';
import '../utils/user_utils.dart';

class PasswordDetail extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;
  final TextEditingController selectedGroupController;
  final TextEditingController selectedPasswordController;
  final String temporizedPassword;
  Function updatePasswordList;
  final Color textColor; // Accept text color dynamically

  PasswordDetail({
    super.key,
    required this.firestore,
    required this.userId,
    required this.selectedGroupController,
    required this.selectedPasswordController,
    required this.updatePasswordList,
    required this.textColor, // Pass textColor as parameter
    required this.temporizedPassword,
  });

  @override
  State<PasswordDetail> createState() => _PasswordDetailState();
}

class _PasswordDetailState extends State<PasswordDetail> {
  bool isReadOnly = true;
  bool showEditIcons = false;
  bool isPasswordVisible = false;
  Map<String, TextEditingController> controllers = {};

  void _updateControllers(Map<String, dynamic> passwords) async {
    List<String> orderedKeys = ['title', 'username', 'password', 'Note'];
    for (String key in orderedKeys) {
      String value = passwords[key] ?? '';
      if (key == 'password') {
        debugPrint('value before decrypt: $value');
        debugPrint('temporizedPassword at password detail: ${widget.temporizedPassword}');
        value = await MyEncrypt.decrypt(widget.temporizedPassword, value);
        debugPrint('value after decrypt: $value');
      }
      if (controllers.containsKey(key)) {
        controllers[key]?.text = value;
      } else {
        controllers[key] = TextEditingController(text: value);
      }
    }
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser(widget.firestore, widget.userId),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.key, color: Colors.yellow),
                  SizedBox(width: 8),
                  Text("Password Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              CircularProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          return const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.key, color: Colors.yellow),
                  SizedBox(width: 8),
                  Text("Password Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('Error fetching data'),
            ],
          );
        } else {
          Map<String, dynamic> passwords = snapshot.data ?? {};
          if (widget.selectedPasswordController.text.isEmpty ||
              widget.selectedGroupController.text.isEmpty ||
              passwords.isEmpty ||
              passwords['groups'][widget.selectedGroupController.text] == null ||
              passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] == null) {
            return const Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.key, color: Colors.yellow),
                      SizedBox(width: 8),
                      Text("Password Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Select password to view details', style: TextStyle(color: Colors.grey)),
                )
              ],
            );
          }
          if (passwords['groups'][widget.selectedGroupController.text] != null &&
              passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] != null) {
            passwords = passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] ?? {};
            _updateControllers(passwords);
          }
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.key, color: Colors.yellow),
                    SizedBox(width: 8),
                    Text("Password Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        List<String> orderedKeys = ['title', 'username', 'password', 'Note'];
                        String key = orderedKeys[index];
                        String value = passwords[key] ?? '';
                        if (!controllers.containsKey(key)) {
                          controllers[key] = TextEditingController(text: value);
                        }
                        TextEditingController fieldController = controllers[key]!;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                margin: EdgeInsets.zero,
                                color: const Color.fromARGB(255, 26, 24, 24),
                                elevation: 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 50.0, top: 5.0, right: 50.0, bottom: 3.0),
                                  child: StatefulBuilder(
                                    builder: (context, setFieldState) {
                                      return TextField(
                                        readOnly: !showEditIcons,
                                        obscureText: key == 'password' ? !isPasswordVisible : false,
                                        decoration: InputDecoration(
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (key == 'password')
                                                IconButton(
                                                  icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                                  onPressed: () {
                                                    setFieldState(() {
                                                      isPasswordVisible = !isPasswordVisible;
                                                    });
                                                  },
                                                ),
                                              IconButton(
                                                icon: const Icon(Icons.copy),
                                                onPressed: () async {
                                                  await Clipboard.setData(ClipboardData(text: fieldController.text));
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        controller: fieldController,
                                        style: TextStyle(color: widget.textColor),  // Set dynamic text color
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(showEditIcons ? Icons.cancel : Icons.edit, color: Colors.white),
                            label: Text(showEditIcons ? "Cancel" : "Edit", style: const TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showEditIcons ? Colors.red : const Color(0xFF00796B),
                            ),
                            onPressed: () {
                              setState(() {
                                showEditIcons = !showEditIcons;
                                isReadOnly = !showEditIcons;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          if (showEditIcons)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () async {
                                try {
                                  await updatePassword(
                                    widget.selectedPasswordController.text,
                                    controllers['title']?.text ?? '',
                                    controllers['username']?.text ?? '',
                                    controllers['password']?.text ?? '',
                                    controllers['Note']?.text ?? '',
                                    widget.selectedGroupController.text,
                                    widget.firestore,
                                    widget.userId,
                                  );
                                  widget.updatePasswordList();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details updated successfully!')));
                                  setState(() {
                                    showEditIcons = false;
                                    isReadOnly = true;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating details: $e')));
                                }
                              },
                              child: const Text("Update Details", style: TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      }
    );
  }
}
