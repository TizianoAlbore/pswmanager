import 'package:flutter/material.dart';

class PassphraseWidget extends StatefulWidget {
  final Function(String) onSelected;

  const PassphraseWidget({Key? key, required this.onSelected}) : super(key: key);

  @override
  State<PassphraseWidget> createState() => _PassphraseWidgetState();
}

class _PassphraseWidgetState extends State<PassphraseWidget> {
  final List<String> words = ['ciao', 'test', 'prova'];
  final Set<String> selectedWords = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select your passphrase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: words.map((word) {
              final isSelected = selectedWords.contains(word);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedWords.remove(word);
                    } else if (selectedWords.length < 3) {
                      selectedWords.add(word);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Mostra in tempo reale le parole selezionate
          Text(
            selectedWords.join(' '),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                widget.onSelected(selectedWords.join(' '));
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
            const SizedBox(width: 16), // Spazio tra i due bottoni
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