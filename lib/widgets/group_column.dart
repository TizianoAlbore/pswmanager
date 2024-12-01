import 'package:flutter/material.dart';
import '../utils/user_utils.dart';
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
    return FutureBuilder(
      future: getGroups(widget.firestore, widget.userId),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                        // Handle group selection
                        debugPrint('Selected Group: ${groups[index]}');
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
