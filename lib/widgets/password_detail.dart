import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordDetail extends StatefulWidget {
  final String title;
  final String value;

  const PasswordDetail({Key? key, required this.title, required this.value}) : super(key: key);
  @override
  State<PasswordDetail> createState() => _PasswordDetailState();
}

class _PasswordDetailState extends State<PasswordDetail> {
  TextEditingController fieldController = TextEditingController();
  bool isReadOnly = true;


  _toggleReadOnly() {
    setState(() {
      isReadOnly = !isReadOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    fieldController.text = widget.value;
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).secondaryHeaderColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          readOnly: isReadOnly,
          decoration: InputDecoration(
            labelText: widget.title,
            labelStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: fieldController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(isReadOnly ? Icons.edit : Icons.save),
                  onPressed: () {
                    setState(() {
                      _toggleReadOnly();
                    });
                  },
                ),
              ],
            ),
          ),
          controller: fieldController,
        ),
      ),
    );
  }
}