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
  bool showEditIcons = false;
  bool isPasswordVisible = false; // Stato per alternare la visibilità della password.

 // Funzione per alternare la modalità di sola lettura.
  _toggleReadOnly() {
    setState(() {
      isReadOnly = !isReadOnly;
    });
  }

  // Funzione per capitalizzare la prima lettera della stringa.
  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input; // Gestisce stringhe vuote.
    return input[0].toUpperCase() + input.substring(1); // Prima lettera maiuscola.
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
                '🔑 Password Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              CircularProgressIndicator(),
            ]
          );
        } else if (snapshot.hasError) {
          return const Column(
            children: [
              Text(
                '🔑 Password Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('Error fetching data'),
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '🔑 Password Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Select password to view details',
                    style: TextStyle(color: Colors.grey)
                  )
                )
              ],
            );
          }
          passwords = passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] ?? {};
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "🔑 Password Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    // Defining keys order
                    List<String> orderedKeys = ['title', 'username', 'password', 'Note'];
                    String key = orderedKeys[index];
                    String value = passwords[key] ?? '';
                    TextEditingController fieldController = TextEditingController(text: value);

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
                                    readOnly: isReadOnly,
                                    obscureText: key == 'password' ? !isPasswordVisible : false,
                                    decoration: InputDecoration(
                                      labelText: _capitalizeFirstLetter(key),
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromARGB(255, 26, 24, 24), // Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Tasto visibilità per la password
                                          if (key == 'password')
                                            IconButton(
                                              icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                              onPressed: () {
                                                setFieldState(() {
                                                  isPasswordVisible = !isPasswordVisible; // Alterna lo stato della visibilità.
                                                });
                                              },
                                            ),
                                          // Tasto copia negli appunti
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
                                          // Tasto modifica, visibile solo in modalità Edit
                                          if (showEditIcons)
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                setState(() {
                                                  _toggleReadOnly(); // Alterna la modalità di sola lettura.
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                    controller: fieldController,
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
              ),
              // Pulsante Edit/Cancel in fondo alla lista.
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: Icon(showEditIcons ? Icons.cancel : Icons.edit),
                  label: Text(showEditIcons ? "Cancel" : "Edit"),
                  onPressed: () {
                    setState(() {
                      showEditIcons = !showEditIcons; // Alterna la visibilità delle icone di modifica.
                    });
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