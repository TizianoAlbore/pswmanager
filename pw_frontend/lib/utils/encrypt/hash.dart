import 'dart:convert';

import 'package:crypto/crypto.dart'; // For hashing the password

// Hash function to store the master passphrase
String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final hashedPassword = sha256.convert(bytes).toString();
  return hashedPassword;
}
