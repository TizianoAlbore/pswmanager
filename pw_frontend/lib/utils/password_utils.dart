import 'dart:math';
import 'dart:convert';
import 'dart:io';

// generatre password function, 
//in input has to take lenght default 12, if digits default yes, 
//if specialChars default yes, special char are !@#$%^&*()-_=+[]{}\|;:'",<>./?
// if capital letters default yes
// every feature has to be added in a charset
// then we have to generate a random password with the charset
String generatePassword({int length = 12, bool digits = true, bool specialChars = true, bool capitalLetters = true}) {
  String charset = 'abcdefghijklmnopqrstuvwxyz';
  if (digits) charset += '0123456789';
  if (specialChars) charset += '!@#\$%^&*()-_=+[]{}\\|;:\'",<>./?';
  if (capitalLetters) charset += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Random random = Random.secure();
  String password = '';
  for (int i = 0; i < length; i++) {
    password += charset[random.nextInt(charset.length)];
  }
  return password;
}

// Generate memorable password, using the dictionary in ./dictionaries
// takes in input language default english (en.txt), length default 12, 
//if special character default yes, if number default yes
// every word has to be capitalized
// the numbers should be put between words and special characters at the end
String generateMemorablePassword({String language = 'en', int length = 12, bool specialChars = true, bool numbers = true}) {
  List<String> words = File('dictionaries/$language.txt').readAsLinesSync();
  Random random = Random.secure();
  String password = '';
  String specialCharset = '!@#\$%^&*()-_=+[]{}\\|;:\'",<>./?';
  while (password.length < length) {
    String word = words[random.nextInt(words.length)];
    word = word[0].toUpperCase() + word.substring(1);
    password += word;
    if (numbers && password.length < length) {
      password += random.nextInt(10).toString();
    }
  }
  if (specialChars) {
    password += specialCharset[random.nextInt(specialCharset.length)];
  }
  return password;
}
