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
  final Color textColor; // Accept dynamic text color

  PasswordDetail({
    super.key,
    required this.firestore,
    required this.userId,
    required this.selectedGroupController,
    required this.selectedPasswordController,
    required this.updatePasswordList,
    required this.textColor,
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
        value = await MyEncrypt.decrypt(widget.temporizedPassword, value);
      }
      if (controllers.containsKey(key)) {
        controllers[key]?.text = value;
      } else {
        controllers[key] = TextEditingController(text: value);
      }
    }
  }

  // Capitalize the first letter of a string
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
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.key, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    "Password Details",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const CircularProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.key, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    "Password Details",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text('Error fetching data', style: Theme.of(context).textTheme.bodyLarge),
            ],
          );
        } else {
          Map<String, dynamic> passwords = snapshot.data ?? {};
          if (widget.selectedPasswordController.text.isEmpty ||
              widget.selectedGroupController.text.isEmpty ||
              passwords.isEmpty ||
              passwords['groups'][widget.selectedGroupController.text] == null ||
              passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] == null) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.key, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        "Password Details",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select password to view details',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
              ],
            );
          }
          passwords = passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] ?? {};
          _updateControllers(passwords);

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.key, color: Colors.yellow),
                    SizedBox(width: 8),
                    Text(
                      "Password Details",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    List<String> orderedKeys = ['title', 'username', 'password', 'Note'];
                    String key = orderedKeys[index];
                    if (!controllers.containsKey(key)) {
                      controllers[key] = TextEditingController(text: passwords[key] ?? '');
                    }
                    TextEditingController fieldController = controllers[key]!;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Column(
                        children: [
                          Card(
                            color: Theme.of(context).colorScheme.surface,
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                readOnly: !showEditIcons,
                                obscureText: key == 'password' ? !isPasswordVisible : false,
                                decoration: InputDecoration(
                                  labelText: _capitalizeFirstLetter(key),
                                  labelStyle: TextStyle(color: widget.textColor),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (key == 'password')
                                        IconButton(
                                          icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordVisible = !isPasswordVisible;
                                            });
                                          },
                                        ),
                                      IconButton(
                                        icon: Icon(Icons.copy, color: widget.textColor),
                                        onPressed: () async {
                                          await Clipboard.setData(ClipboardData(text: fieldController.text));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Copied to clipboard')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                controller: fieldController,
                                style: TextStyle(color: widget.textColor),
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
      },
    );
  }
}
