import 'package:cloud_firestore/cloud_firestore.dart';

//add user to firestore
addUser(userCredential, _firestore, _emailController, ) async {

  String userId = userCredential.user!.uid;
    
  Map<String, Map<String, String> > passwords = {};
    await _firestore.collection('users').doc(userId).set({
    'email': _emailController.text.trim(),
    'passwords': passwords,
  });
}

//add password to user
addPassword(title, hashed_password, note, _firestore, userId) async{
  Map<String, String> password = {
    "Title": title,
    "password": hashed_password,
    "Note": note
  };
  await _firestore.collection('users').doc(userId).update({
    'passwords': FieldValue.arrayUnion([password]),
  });
}

