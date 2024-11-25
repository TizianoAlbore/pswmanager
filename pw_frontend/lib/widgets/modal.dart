import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../utils/password_utils.dart';
import '../utils/user_utils.dart';
import 'package:flutter/services.dart';

class CustomModal extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;

  const CustomModal({Key? key, required this.firestore, required this.userId}) : super(key: key);

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
  final TextEditingController lengthController = TextEditingController(text: '16');

  @override
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
                        onPressed: () => passwordController.text = generatePassword(length: lengthController.text.isEmpty ? 16 : int.parse(lengthController.text),
                                                                                    digits: _includeDigits,
                                                                                    capitalLetters:  _includeCapitalLetters,
                                                                                    specialChars: _includeSpecialChars),
                      ),
                      IconButton(
                        icon: Icon(
                          _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
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
                }
              ),
              Row(
                children: [
                  ToggleButtons(
                    isSelected: [_includeCapitalLetters, _includeSpecialChars, _includeDigits],
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
                onChanged: (value) => {int.parse(value) > 50 ? lengthController.text = '50' : null},
              ),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              DropdownMenu(
                controller: groupController,
                dropdownMenuEntries: getGroups(widget.firestore, widget.userId),
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
            // Handle save action
            if (_formKey.currentState!.validate()) {
              try {
                await addPassword(titleController.text,
                                  usernameController.text,
                                  passwordController.text, 
                                  noteController.text, 
                                  groupController.text, 
                                  widget.firestore, 
                                  widget.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password added successfully')),
              );
              titleController.clear();
              passwordController.clear();
              noteController.clear();
              groupController.clear();
              Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add password: ${e.toString()}')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter valid data')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}