import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

// hash function, used to store master passhprase
String hashPassword(String password){
  final bytes = utf8.encode(password);
  final hashedPassword = sha256.convert(bytes).toString();
  return hashedPassword;
}

// AES encryption function using AesCbc with 256 bits
Future<String> encrypt(String password, String text) async {
  final secretKey = SecretKey.fromUtf8(password);
  final nonce = Nonce.randomBytes(16);
  final algorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
  final encrypter = Encrypter(algorithm, secretKey: secretKey);
  final encrypted = await encrypter.encrypt(text, nonce: nonce);
  return encrypted.base64;
}

// AES decryption function using AesCbc with 256 bits
Future<String> decrypt(String password, String text) async {
  final secretKey = SecretKey.fromUtf8(password);
  final nonce = Nonce.randomBytes(16);
  final algorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());
  final encrypter = Encrypter(algorithm, secretKey: secretKey);
  final decrypted = await encrypter.decrypt(Encrypted.fromBase64(text), nonce: nonce);
  return decrypted;
}

