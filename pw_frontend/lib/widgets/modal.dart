import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/password_utils.dart';
import '../utils/user_utils.dart';
    
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
                        onPressed: () => passwordController.text = generatePassword(length: 16, digits: true, specialChars: true, capitalLetters: true),
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
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              TextFormField(
                controller: groupController,
                decoration: const InputDecoration(labelText: 'Group'),
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
                await addPassword(titleController.text, usernameController.text, passwordController.text, noteController.text, groupController.text, widget.firestore, widget.userId);
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