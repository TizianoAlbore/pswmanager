import 'package:flutter/material.dart';
import 'package:pw_frontend/utils/totp/totp2.dart';

class TotpCard extends StatefulWidget {
  final Totp totp;
  final String name;
  final String service;
  final ValueNotifier<int> remainingTimeNotifier;

  const TotpCard({required this.totp, required this.remainingTimeNotifier, required this.name, required this.service, super.key});

  @override
  _TotpCardState createState() => _TotpCardState();
}
class _TotpCardState extends State<TotpCard> {
  late int _totpCode;

  @override
  void initState() {
    super.initState();
    _totpCode = widget.totp.generateTOTPCode();
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
         _totpCode = widget.totp.generateTOTPCode();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_totpCode.toString()),
          Text('Name: ${widget.name}'),
          Text('Service: ${widget.service}'),
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