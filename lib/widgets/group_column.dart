import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupColumnPage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;

  const GroupColumnPage({Key? key, required this.firestore, required this.userId}) : super(key: key);

  @override
  State<GroupColumnPage> createState() => _GroupColumnPageState();
}

class _GroupColumnPageState extends State<GroupColumnPage> {
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
    final List<String> groups = [
      "Social Media",
      "Work",
      "Personal",
      "Banking",
      "Others"
    ];

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
                  // Handle group selection
                  debugPrint('Selected Group: ${groups[index]}');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Group Passwords Column
  Widget _buildGroupPasswordsColumn() {
    final List<String> passwords = [
      "Facebook",
      "Twitter",
      "LinkedIn",
      "GitHub",
      "Google"
    ];

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
            itemCount: passwords.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(passwords[index]),
                onTap: () {
                  // Handle password selection
                  debugPrint('Selected Password: ${passwords[index]}');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Password Details Column
  Widget _buildPasswordDetailsColumn() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Password Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Text("Select a password to view details"),
      ],
    );
  }
}
