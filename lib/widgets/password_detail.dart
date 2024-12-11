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
  bool isPasswordVisible = false;
  Map<String, TextEditingController> controllers = {};

  void _updateControllers(Map<String, dynamic> passwords) {
    List<String> orderedKeys = ['title', 'username', 'password', 'Note'];
    for (String key in orderedKeys) {
      String value = passwords[key] ?? '';
      if (controllers.containsKey(key)) {
        // Aggiorna il valore del controller esistente
        controllers[key]?.text = value;
      } else {
        // Crea un nuovo controller se non esiste
        controllers[key] = TextEditingController(text: value);
      }
    }
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
          if (passwords['groups'][widget.selectedGroupController.text] != null &&
          passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] != null) {
            passwords = passwords['groups'][widget.selectedGroupController.text][widget.selectedPasswordController.text] ?? {};
            // Aggiorna i controller con i nuovi valori
            _updateControllers(passwords);
          }
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "🔑 Password Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: Column(
                  children: [
                    // Lista di card
                    ListView.builder(
                      shrinkWrap: true, // Adatta la lista al contenuto.
                      physics: const NeverScrollableScrollPhysics(), // Disabilita lo scrolling interno.
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        // Defining keys order
                        List<String> orderedKeys = ['title', 'username', 'password', 'Note'];
                        String key = orderedKeys[index];
                        String value = passwords[key] ?? '';
                        // Inizializza il controller se non esiste
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
                                              // Tasto visibilità per la password
                                              if (key == 'password')
                                                IconButton(
                                                  icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                                  onPressed: () {
                                                    setFieldState(() {
                                                      isPasswordVisible = !isPasswordVisible;
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
                    // Pulsanti Edit/Cancel e Update Details
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            // Pulsante Edit/Cancel
                            ElevatedButton.icon(
                            icon: Icon(showEditIcons ? Icons.cancel : Icons.edit,
                              color: Colors.white,
                            ),
                            label: Text(showEditIcons ? "Cancel" : "Edit",
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: showEditIcons ? Colors.red : const Color(0xFF00796B),
                            ),
                            onPressed: () {
                              setState(() {
                              showEditIcons = !showEditIcons; // Alterna la visibilità delle icone di modifica.
                              isReadOnly = !showEditIcons; // Attiva/disattiva la modalità di sola lettura.
                              });
                            },
                            ),
                          const SizedBox(width: 10), // Spazio tra i pulsanti
                          // Pulsante Update Details (solo in modalità Edit)
                          if (showEditIcons)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green, // Colore verde.
                              ),
                              onPressed: () async {
                                try {
                                  // Chiama la funzione di aggiornamento
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

                                  // Mostra il messaggio di successo
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Details updated successfully!'),
                                    ),
                                  );

                                  // Esci dalla modalità Edit
                                  setState(() {
                                    showEditIcons = false;
                                    isReadOnly = true;
                                  });
                                } catch (e) {
                                  // Mostra messaggio di errore
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error updating details: $e'),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Update Details",
                                style: TextStyle(color: Colors.white),
                              ),
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