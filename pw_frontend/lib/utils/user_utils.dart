import 'package:cloud_firestore/cloud_firestore.dart';

//add user to firestore with basic schema
Future<void> addUser(userCredential, firestore, emailController, ) async {

  String userId = userCredential.user!.uid;
    
  Map<String, Map<String, String> > passwords = {};
    await firestore.collection('users').doc(userId).set({
    'email': emailController.text.trim(),
    'passwords': passwords,
  });
}

//add password to user
Future<void> addPassword(String title, username, hashedPassword, note, firestore, userId) async{
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  //check if user exists
  if (userCollection.exists) {

    Map<String, String> password = {
      "username": username,
      "password": hashedPassword,
      "Note": note
    };

    if (userCollection['passwords']!.containsKey(title)) {
      await firestore.collection('users').doc(userId).update({
        'passwords.$title': password,
    });
    } else {
      //throw exception if title already exists, we have to update entry not add a new one
      throw Exception('Title already exists');
    }
  } 
  else {
    throw Exception('User not found');
  }  
}


