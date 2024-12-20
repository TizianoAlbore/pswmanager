import 'package:flutter/material.dart';
import '../utils/user_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupColumnPage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;
  final TextEditingController selectedGroupController;
  Function callback_selectedGroup;
  final Color textColor;

  GroupColumnPage({
    super.key,
    required this.firestore,
    required this.userId,
    required this.selectedGroupController,
    required this.callback_selectedGroup,
    required this.textColor,
  });

  @override
  State<GroupColumnPage> createState() => _GroupColumnPageState();
}

class _GroupColumnPageState extends State<GroupColumnPage> {
  bool _isAddingGroup = false;
  final TextEditingController _newGroupController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGroups(widget.firestore, widget.userId),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder, color: Colors.yellow),
                  const SizedBox(width: 8),
                  Text(
                    "Groups",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const CircularProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyLarge),
          );
        } else {
          List<String> groups = snapshot.data ?? [];
          groups.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder, color: Colors.yellow),
                    const SizedBox(width: 8),
                    Text(
                      "Groups",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length + 1,
                  itemBuilder: (context, index) {
                    if (index == groups.length) {
                      return _isAddingGroup
                          ? _buildAddGroupTile(groups)
                          : ListTile(
                              trailing: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isAddingGroup = true;
                                  });
                                },
                                icon: const Icon(Icons.add_rounded),
                                color: Colors.green,
                              ),
                            );
                    }
                    return _buildGroupTile(groups, index);
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  ListTile _buildAddGroupTile(List<String> groups) {
    return ListTile(
      title: TextField(
        autofocus: true,
        controller: _newGroupController,
        decoration: const InputDecoration(
          hintText: 'Enter group name',
        ),
        onSubmitted: (value) async {
          if (value.isNotEmpty) {
            try {
              await addGroup(value, widget.firestore, widget.userId);
              setState(() {
                groups.add(value);
                groups.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                _isAddingGroup = false;
                _newGroupController.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Group $value added')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
              );
            }
          }
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.cancel),
            color: Colors.red,
            onPressed: () {
              setState(() {
                _isAddingGroup = false;
                _newGroupController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            color: Colors.green,
            onPressed: () async {
              if (_newGroupController.text.isNotEmpty) {
                try {
                  await addGroup(_newGroupController.text, widget.firestore, widget.userId);
                  setState(() {
                    groups.add(_newGroupController.text);
                    groups.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                    _isAddingGroup = false;
                    _newGroupController.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Group ${_newGroupController.text} added')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(List<String> groups, int index) {
    return Column(
      children: [
        ListTile(
          title: Text(
            groups[index],
            style: TextStyle(
              color: (widget.selectedGroupController.text == groups[index])
                  ? Theme.of(context).colorScheme.primary
                  : widget.textColor,
            ),
          ),
          onTap: () {
            setState(() {
              widget.selectedGroupController.text = groups[index];
              widget.callback_selectedGroup(groups[index]);
            });
          },
          selected: widget.selectedGroupController.text == groups[index],
          selectedTileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          trailing: IconButton(
            icon: const Icon(Icons.remove_rounded),
            color: Colors.red[400],
            onPressed: () async {
              try {
                await deleteGroup(groups[index], widget.firestore, widget.userId);
                setState(() {
                  groups.removeAt(index);
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')),
                );
              }
            },
          ),
        ),
        const Divider(),
      ],
    );
  }
}
