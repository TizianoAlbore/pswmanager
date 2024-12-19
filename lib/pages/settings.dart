import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pw_frontend/utils/psw_holder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/update_master_passphrase.dart';
import '../widgets/drawer.dart';
import '../main.dart'; // Import for theme updates
import 'theme_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class SettingsArguments {
  final PasswordHolder temporizedPassword;

  SettingsArguments(this.temporizedPassword);
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
    currentThemeNotifier.value = getTheme(theme);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user ==null){
      Future.microtask((){
        Navigator.pop(context);
        Navigator.pushNamed(context, '/');
      });
    }
    
    final args =
        ModalRoute.of(context)?.settings.arguments as SettingsArguments?;
    final PasswordHolder temporizedPassword =
        args?.temporizedPassword ?? PasswordHolder();

    if (temporizedPassword.temporizedMasterPassphrase == ''){
      Navigator.pop(context);
      FirebaseAuth.instance.signOut();
      Navigator.pushNamed(context, '/');
    }
    
    return Scaffold(
        drawer: DrawerWidget(temporizedPassword: temporizedPassword),
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
            padding: const EdgeInsets.only(
                top: 12), // Aggiunge padding solo dall'alto
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    width: 400,
                    height: 500,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(12), // Raggio di arrotondamento
                      border: Border.all(
                          color: Colors.grey, width: 1), // Bordo opzionale
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Password Change Section
                        const Text(
                          'Change Password',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 300, // Larghezza fissa
                          child: TextField(
                            controller: _oldpasswordController,
                            decoration: const InputDecoration(
                                labelText: 'Current Password'),
                            obscureText: true,
                          ),
                        ),
                        SizedBox(
                          width: 300, // Larghezza fissa
                          child: TextField(
                            controller: _newpasswordController,
                            decoration: const InputDecoration(
                                labelText: 'New Password'),
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            await changePassword(
                                context,
                                _oldpasswordController.text,
                                _newpasswordController.text);
                          },
                          child: const Text('Change Password'),
                        ),

                        const Divider(height: 50),

                        // Theme Selection Section
                        const Text(
                          'App Theme',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          width: 300, // Larghezza fissa del contenitore
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(12), // Raggio di arrotondamento
                          ), 
                          alignment: Alignment
                              .centerLeft, // Allinea i contenuti a sinistra
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Allinea i figli a sinistra
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets
                                    .zero, // Rimuove il padding interno
                                horizontalTitleGap:
                                    0, // Riduce lo spazio tra il Radio e il testo
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
                                contentPadding: EdgeInsets.zero,
                                horizontalTitleGap: 0,
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
                                contentPadding: EdgeInsets.zero,
                                horizontalTitleGap: 0,
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
                        )
                      ],
                    ),
                  ),
                ])));
  }
}
