import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pw_frontend/utils/encrypt/aes.dart';
import '../utils/password_utils.dart';
import '../utils/user_utils.dart';
import 'package:flutter/services.dart';

class CustomModal extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;
  final String selectedGroupText;
  final String temporizedPassword;
  Function callbackUpdate;
  CustomModal(
      {super.key,
      required this.firestore,
      required this.userId,
      required this.selectedGroupText,
      required this.callbackUpdate,
      required this.temporizedPassword});

  @override
  State<CustomModal> createState() => _CustomModalState();
}

class _CustomModalState extends State<CustomModal> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  bool _includeDigits = true;
  bool _includeSpecialChars = true;
  bool _includeCapitalLetters = true;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController groupController = TextEditingController();
  final TextEditingController lengthController =
      TextEditingController(text: '16');

  @override
  void initState() {
    super.initState();
    groupController.text =
        widget.selectedGroupText; // Inizializza il valore del controller
  }

  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Entry'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                  controller: passwordController,
                  obscureText: _passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => passwordController.text =
                              generatePassword(
                                  length: lengthController.text.isEmpty
                                      ? 16
                                      : int.parse(lengthController.text),
                                  digits: _includeDigits,
                                  capitalLetters: _includeCapitalLetters,
                                  specialChars: _includeSpecialChars),
                        ),
                        IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          onPressed: () => _toggle(),
                        ),
                      ],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  }),
              Row(
                children: [
                  ToggleButtons(
                    isSelected: [
                      _includeCapitalLetters,
                      _includeSpecialChars,
                      _includeDigits
                    ],
                    onPressed: (int index) {
                      setState(() {
                        if (index == 0) {
                          _includeCapitalLetters = !_includeCapitalLetters;
                        } else if (index == 1) {
                          _includeSpecialChars = !_includeSpecialChars;
                        } else if (index == 2) {
                          _includeDigits = !_includeDigits;
                        }
                      });
                    },
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Capital Letters'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Symbols'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Numbers'),
                      ),
                    ],
                  ),
                ],
              ),
              TextFormField(
                controller: lengthController,
                decoration: const InputDecoration(labelText: 'Length'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => {
                  int.parse(value) > 50 ? lengthController.text = '50' : null
                },
              ),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              FutureBuilder<List<String>>(
                future: getGroups(widget.firestore, widget.userId),
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<DropdownMenuItem<String>> items =
                        snapshot.data?.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList() ??
                            [];

                    return DropdownButtonFormField<String>(
                      items: items,
                      value: items.isNotEmpty ? groupController.text : null,
                      onChanged: (String? value) {
                        setState(() {
                          groupController.text = value!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Group'),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                String cryptedPassword = await MyEncrypt.encrypt(
                    widget.temporizedPassword, passwordController.text);
                await addPassword(
                  titleController.text,
                  usernameController.text,
                  cryptedPassword,
                  noteController.text,
                  groupController.text,
                  widget.firestore,
                  widget.userId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password added successfully')),
                );
                widget.callbackUpdate();
                titleController.clear();
                passwordController.clear();
                noteController.clear();
                //groupController.clear();
                lengthController.clear();
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to add password, maybe relogin: ${e.toString()}')),
                );
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
