import 'package:flutter/material.dart';
import '../utils/password_utils.dart'; // Import della funzione

class PassphraseWidget extends StatefulWidget {
  final Function(String) onSelected;

  const PassphraseWidget({Key? key, required this.onSelected}) : super(key: key);

  @override
  State<PassphraseWidget> createState() => _PassphraseWidgetState();
}

class _PassphraseWidgetState extends State<PassphraseWidget> {
  late List<String> generatedPasswords = [];

  @override
  void initState() {
    super.initState();
    _generateNewPasswords();
  }

  Future<void> _generateNewPasswords() async {
    List<Future<String>> passwordFutures = List.generate(3, (_) => generateMemorablePassword());
    List<String> newPasswords = await Future.wait(passwordFutures);

    setState(() {
      generatedPasswords = newPasswords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select your passphrase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mostra le password generate
          ...generatedPasswords.map((password) {
            return GestureDetector(
              onTap: () {
                widget.onSelected(password); // Passa la password selezionata
                Navigator.of(context).pop(); // Chiude il dialog
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  password,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bottone per rigenerare il set di password
            TextButton.icon(
              onPressed: _generateNewPasswords,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate new'),
            ),
            // Bottone per chiudere il dialog
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}