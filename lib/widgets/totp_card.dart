import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pw_frontend/utils/totp/totp2.dart';
import 'package:flutter/services.dart';
import 'package:pw_frontend/utils/user_utils.dart';

class TotpCard extends StatefulWidget {
  final Totp totp;
  final String id;
  final String name;
  final String service;
  final ValueNotifier<int> remainingTimeNotifier;
  final VoidCallback onDelete;

  const TotpCard({
    required this.totp,
    required this.remainingTimeNotifier,
    required this.name,
    required this.service,
    required this.id,
    required this.onDelete,
    super.key,
  });

  @override
  TotpCardState createState() => TotpCardState();
}

class TotpCardState extends State<TotpCard> {
  late int _totpCode;
  late TextEditingController _nameController;
  late TextEditingController _serviceController;

  @override
  void initState() {
    super.initState();
    _totpCode = widget.totp.generateTOTPCode();
    _nameController = TextEditingController(text: widget.name);
    _serviceController = TextEditingController(text: widget.service);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _totpCode.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TOTP code copied to clipboard')),
    );
  }

  void _deleteTotp() async{
    try {
      await deleteTotp(FirebaseFirestore.instance, FirebaseAuth.instance.currentUser!.uid, widget.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TOTP deleted')),
      );
      widget.onDelete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete TOTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth * 0.05;
        double chipFontSize = constraints.maxWidth * 0.05;

        const double minFontSize = 15.0;
        fontSize = fontSize < minFontSize ? minFontSize : fontSize;
        chipFontSize = chipFontSize < minFontSize ? minFontSize : chipFontSize;

        return Card(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const SizedBox(width: 48), // Empty space to balance the copy icon
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: _totpCode.toString()),
                              readOnly: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: chipFontSize, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.teal[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.teal),
                            onPressed: _copyToClipboard,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: Colors.teal),
                    const SizedBox(width: 8.0),
                    Text(
                            widget.name,
                            style: TextStyle(fontSize: fontSize),
                          ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.business, color: Colors.teal),
                    const SizedBox(width: 8.0),
                    Text(
                            widget.service,
                            style: TextStyle(fontSize: fontSize),
                          ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.teal),
                      onPressed: _deleteTotp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}