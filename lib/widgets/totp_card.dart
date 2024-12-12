import 'package:flutter/material.dart';
import 'package:pw_frontend/utils/totp/totp.dart';

class TotpCard extends StatefulWidget {
  final Totp totp;
  final ValueNotifier<int> remainingTimeNotifier;

  const TotpCard({required this.totp, required this.remainingTimeNotifier, Key? key}) : super(key: key);

  @override
  _TotpCardState createState() => _TotpCardState();
}
class _TotpCardState extends State<TotpCard> {
  late String _totpCode;

  @override
  void initState() {
    super.initState();
    _totpCode = widget.totp.now();
    widget.remainingTimeNotifier.addListener(_updateTotpCode);
  }

  @override
  void dispose() {
    widget.remainingTimeNotifier.removeListener(_updateTotpCode);
    super.dispose();
  }

  void _updateTotpCode() {
    if (widget.remainingTimeNotifier.value == 0) {
      setState(() {
        _totpCode = widget.totp.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_totpCode),
          TotpProgressBar(remainingTimeNotifier: widget.remainingTimeNotifier),
        ],
      ),
    );
  }
}

class TotpProgressBar extends StatelessWidget {
  final ValueNotifier<int> remainingTimeNotifier;

  const TotpProgressBar({required this.remainingTimeNotifier, super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: remainingTimeNotifier,
      builder: (context, remainingTime, child) {
        return LinearProgressIndicator(
          value: remainingTime / 30.0,
        );
      },
    );
  }
}