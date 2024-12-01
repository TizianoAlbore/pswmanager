import 'package:flutter/material.dart';

class GroupColumnPage extends StatelessWidget {
  const GroupColumnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager Dashboard'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildGroupsColumn(), // Groups Column
          ),
          Expanded(
            flex: 1,
            child: _buildGroupPasswordsColumn(), // Group Passwords Column
          ),
          Expanded(
            flex: 2,
            child: _buildPasswordDetailsColumn(), // Password Details Column
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Password Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              "Select a password to view details.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
