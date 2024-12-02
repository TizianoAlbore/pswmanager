import 'package:flutter/material.dart';
import 'package:pw_frontend/widgets/password_detail.dart';
import '../utils/user_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupColumnPage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;

  const GroupColumnPage({super.key, required this.firestore, required this.userId});

  @override
  State<GroupColumnPage> createState() => _GroupColumnPageState();

}

class _GroupColumnPageState extends State<GroupColumnPage> {

  final TextEditingController _selectedGroupController = TextEditingController();
  final TextEditingController _selectedPasswordController = TextEditingController();

  @override 
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildGroupsColumn(), 
          ),
          Expanded(
            flex: 1,
            child: _buildGroupPasswordsColumn(),
          ),
          Expanded(
            flex: 2,
            child: _buildPasswordDetailsColumn(), 
          ),
        ],
      ),
    );
  }

  // Groups Column
  Widget _buildGroupsColumn() {
    return FutureBuilder(
      future: getGroups(widget.firestore, widget.userId),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              Text(
                'Groups',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              CircularProgressIndicator(),
            ]
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<String> groups = snapshot.data ?? [];
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Groups",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(groups[index]),
                      onTap: () {
                        setState(() {
                          _selectedGroupController.text = groups[index];
                        });
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red[400],
                        onPressed: () async {
                          try {
                            await deleteGroup(groups[index], widget.firestore, widget.userId);
                            setState(() {
                              groups.removeAt(index);
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$e'),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // Group Passwords Column
  Widget _buildGroupPasswordsColumn() {
    return FutureBuilder(
      future: getUser(widget.firestore, widget.userId),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              Text(
                'Group Passwords',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              CircularProgressIndicator(),
            ]
          );
        } else if (snapshot.hasError) {
          return const Column(
            children: [
              Text(
                'Select a group to view passwords',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),     
            ],
          );
        } else {
          Map<String, dynamic> passwords = snapshot.data ?? {};
          Map<String, dynamic> passwordsList = passwords['groups'][_selectedGroupController.text] ?? {};
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Group Passwords",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: passwordsList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(passwordsList.values.elementAt(index)['title']),
                      onTap: () {
                        setState(() {
                          _selectedPasswordController.text = passwordsList.keys.elementAt(index);
                        });
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red[400],
                        onPressed: () async {
                          try {
                            await deletePassword(passwordsList.keys.elementAt(index), widget.firestore, widget.userId);
                            setState(() {
                                passwordsList.remove(passwordsList.keys.elementAt(index));
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$e'),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      }
    );
  }
  // Password Details Column
  Widget _buildPasswordDetailsColumn() {
    return FutureBuilder(
      future: getUser(widget.firestore, widget.userId),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              Text(
                'Password Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              CircularProgressIndicator(),
            ]
          );
        } else if (snapshot.hasError) {
          return const Column(
            children: [
              Text(
                'Password Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('Select a password to view details'),
            ]
          );
        } else {
          Map<String, dynamic> passwords = snapshot.data ?? {};
          if (  _selectedPasswordController.text.isEmpty ||
                _selectedGroupController.text.isEmpty ||
                passwords.isEmpty ||
                passwords['groups'][_selectedGroupController.text] == null ||
                passwords['groups'][_selectedGroupController.text][_selectedPasswordController.text] == null) {
            return const Column(
              children: [
                Text(
                  'Password Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('No password details available'),
              ],
            );
          }
          passwords = passwords['groups'][_selectedGroupController.text][_selectedPasswordController.text] ?? {};
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Passwords Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: passwords.length,
                  itemBuilder: (context, index) {
                    String key = passwords.keys.elementAt(index);
                    String value = passwords[key];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PasswordDetail(title: key, value: value),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      }
    );
  }
}
