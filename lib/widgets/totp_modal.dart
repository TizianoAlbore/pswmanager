import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/user_utils.dart';

class AddTotpModal extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;
  Function onAdding;
  AddTotpModal({super.key, required this.firestore, required this.userId, required this.onAdding});

  @override
  AddTotpModalState createState() => AddTotpModalState();
}

class AddTotpModalState extends State<AddTotpModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serviceController = TextEditingController();
  final _secretController = TextEditingController();
  bool _isSecretVisible = false;
  int _period = 30;
  int _digits = 6;

  @override
  void dispose() {
    _nameController.dispose();
    _serviceController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _submit() async{
    if (_formKey.currentState!.validate()) {
      try{
        await addTotp(widget.firestore, widget.userId, _nameController.text, _serviceController.text, /* _algorithm,*/ _period, _digits, _secretController.text);
        Navigator.of(context).pop({
          'name': _nameController.text,
          'service': _serviceController.text,
          'secret': _secretController.text,
          'period': _period,
          'digits': _digits,
          // 'algorithm': _algorithm,
        });
        widget.onAdding();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TOTP added'))
        );
      } catch (e) {
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
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _serviceController,
                    decoration: const InputDecoration(
                      labelText: 'Service',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a service';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _secretController,
                    obscureText: !_isSecretVisible,
                    decoration: InputDecoration(
                      labelText: 'Secret',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isSecretVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSecretVisible = !_isSecretVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a secret';
                      }
                      return null;
                    },
                  ),
                ),
                ExpansionTile(
                  title: const Text('Advanced Settings'),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              initialValue: _period.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Period (seconds)',
                                prefixIcon: Icon(Icons.timer),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty || int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _period = int.tryParse(value) ?? 30;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              initialValue: _digits.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Digits',
                                prefixIcon: Icon(Icons.confirmation_number),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty || int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _digits = int.tryParse(value) ?? 6;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
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