import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/user_utils.dart';

class AddTotpModal extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;
  const AddTotpModal({super.key, required this.firestore, required this.userId});

  @override
  _AddTotpModalState createState() => _AddTotpModalState();
}

class _AddTotpModalState extends State<AddTotpModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _secretController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      try{addTotp(widget.firestore, widget.userId, _titleController.text, _secretController.text);
      Navigator.of(context).pop({
        'title': _titleController.text,
        'secret': _secretController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TOTP added'))
        );
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add TOTP'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New TOTP Entry'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _secretController,
              decoration: const InputDecoration(labelText: 'Secret'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a secret';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}