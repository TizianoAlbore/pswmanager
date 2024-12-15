import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/update_masterPassphrase.dart';
import '../widgets/drawer.dart';
import '../main.dart'; // Import for theme updates

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _oldpasswordController = TextEditingController();

  String? _selectedTheme; // Tracks the selected theme

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load saved theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme') ?? 'dark'; // Default to dark
    });
  }

  // Save the theme preference to SharedPreferences and update the global theme
  Future<void> _saveThemePreference(String theme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);

    // Update the global theme immediately
    updateTheme(theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password Change Section
            const Text(
              'Change Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
                await changePassword(
                  context, 
                  _oldpasswordController.text, 
                  _newpasswordController.text
                );
              },
              child: const Text('Change Password'),
            ),
            const Divider(height: 40),

            // Theme Selection Section
            const Text(
              'App Theme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Light Theme'),
              leading: Radio<String>(
                value: 'light',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value;
                  });
                  _saveThemePreference(value!);
                },
              ),
            ),
            ListTile(
              title: const Text('Dark Theme'),
              leading: Radio<String>(
                value: 'dark',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value;
                  });
                  _saveThemePreference(value!);
                },
              ),
            ),
            ListTile(
              title: const Text('Colorblind Theme'),
              leading: Radio<String>(
                value: 'colorblind',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value;
                  });
                  _saveThemePreference(value!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
