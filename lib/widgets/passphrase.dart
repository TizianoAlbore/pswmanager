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
      title: const Text('Seleziona fino a 3 parole'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: words.map((word) {
          return CheckboxListTile(
            title: Text(word),
            value: selectedWords.contains(word),
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true && selectedWords.length < 3) {
                  selectedWords.add(word);
                } else {
                  selectedWords.remove(word);
                }
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSelected(selectedWords.join(' '));
            Navigator.of(context).pop();
          },
          child: const Text('Conferma'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
      ],
    );
  }
}