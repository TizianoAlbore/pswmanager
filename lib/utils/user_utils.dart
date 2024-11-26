import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Aggiungi un utente a Firestore con uno schema di base
Future<void> addUser(userCredential, firestore, emailController) async {
  String userId = userCredential.user!.uid;

  Map<String, Map<String, Map<String, String>>> groups = {};
  await firestore.collection('users').doc(userId).set({
    'email': emailController.text.trim(),
    'groups': groups,
  });
}

List<DropdownMenuEntry<String>> getGroups(FirebaseFirestore firestore, String userId) {
  List<DropdownMenuEntry<String>> groups = [];
   firestore.collection('users').doc(userId).get().then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      data['groups'].forEach((key, value) {
        groups.add(DropdownMenuEntry<String>(
          value: key,
          label: key.toString(),
        ));
      });
    }
  });
  return groups;
}
//add password entry to firestore
Future<void> addPassword(String title, String username, String cryptPassword, String note, String group, FirebaseFirestore firestore, String userId) async {
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  
  //check if user exists
  if (userCollection.exists) {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, String> password = {
      'title': title,
      'username': username,
      'password': cryptPassword,
      'Note': note,
    };

    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;

    //check if group exists
    if ((userData['groups'] ?? {}).containsKey(group)) {
      //check if id already exists, if not add password
      if (!(userData['groups.$group'] ?? {}).containsKey(id)) {
        await firestore.collection('users').doc(userId).update({
          'groups.$group.$id': password,
        });
      } else {
        //if id already exists throw exception
        throw Exception('Title already exists');
      }
    } else {
      //if group does not exist, create group and add password
      await firestore.collection('users').doc(userId).update({
        'groups.$group': {id: password},
      });
    }
  } else {
    throw Exception('User not found');
  }
}



