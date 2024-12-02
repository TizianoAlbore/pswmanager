import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/user_utils.dart';

class GroupModal extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;

  const GroupModal({super.key, required this.firestore, required this.userId});

  @override
  State<GroupModal> createState() => _GroupModalState();
}

class _GroupModalState extends State<GroupModal> {
  
  final _formKey = GlobalKey<FormState>();

  final TextEditingController groupController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Group'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: groupController,
                decoration: const InputDecoration(labelText: 'Group'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group';
                  }
                  return null;
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
                await addGroup(groupController.text, widget.firestore, widget.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Group added successfully')),
                );
                groupController.clear();
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add group: ${e.toString()}')),
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