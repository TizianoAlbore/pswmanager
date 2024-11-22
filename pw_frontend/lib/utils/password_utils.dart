import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

String generateRandomPassword(length){
  final random = Random.secure();
  const specialChars = '!@#%^&*()_+';
  const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const digits = '0123456789';
  const allChars = '$letters$digits$specialChars';
  final String password = List.generate(length, (index) {
    final index = random.nextInt(allChars.length);
    return allChars[index];
  }).join();
  return password;
}

String hashPassword(String password){
  final bytes = utf8.encode(password);
  final hashedPassword = sha256.convert(bytes).toString();
  return hashedPassword;
}

String dehashPassword(String hashedPassword){
  final bytes = utf8.encode(hashedPassword);
  final password = sha256.convert(bytes).toString();
  return password;
}

// TODO
//String generateRememberablePassword(){
//  return rememberablePassword;
//}
