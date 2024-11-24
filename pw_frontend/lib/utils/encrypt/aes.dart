import 'dart:convert' as convert;
import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart'; // For hashing the password

class MyEncrypt {
  // Hash function to ensure the key is 256 bits
  static List<int> hashPassword(String password) {
    final bytes = convert.utf8.encode(password);
    final hashedPassword = sha256.convert(bytes).bytes;
    return hashedPassword;
  }

  static Future<String> encrypt(String key, String plaintext) async {
    final secretKey = SecretKey(hashPassword(key));
    final nonce = AesGcm.with256bits().newNonce();
    final algorithm = AesGcm.with256bits();

    final secretBox = await algorithm.encrypt(
      convert.utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    // Combine nonce, ciphertext, and MAC for easier storage
    final combined = nonce + secretBox.cipherText + secretBox.mac.bytes;
    return convert.base64.encode(combined);
  }

  static Future<String> decrypt(String key, String ciphertext) async {
    final secretKey = SecretKey(hashPassword(key));
    final algorithm = AesGcm.with256bits();

    final combined = convert.base64.decode(ciphertext);
    final nonce = combined.sublist(0, 12);
    final mac = Mac(combined.sublist(combined.length - 16));
    final cipherText = combined.sublist(12, combined.length - 16);

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);

    final decrypted = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return convert.utf8.decode(decrypted);
  }
}
