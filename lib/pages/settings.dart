import 'package:flutter/material.dart';
import '../utils/update_masterPassphrase.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _oldpasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false
        ),
      body: Padding(
        padding: const EdgeInsets.all(100.0),
        child: Column(
          children: [
            TextField(
              controller: _oldpasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            TextField(
              controller: _newpasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await changePassword(context, _oldpasswordController.text, _newpasswordController.text);
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
