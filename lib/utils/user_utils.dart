import 'package:cloud_firestore/cloud_firestore.dart';

//add user to firestore
Future<void> addUser(userCredential, firestore, emailController) async {
  String userId = userCredential.user!.uid;

  Map<String, Map<String, Map<String, String>>> groups = {
    'General': {},
  };
  await firestore.collection('users').doc(userId).set({
    'email': emailController.text.trim(),
    'groups': groups,
  });
}

Future<List<String>> getGroups(FirebaseFirestore firestore, String userId) async {
  List<String> groups = [];
  await firestore.collection('users').doc(userId).get().then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      data['groups'].forEach((key, value) {
        groups.add(key.toString());
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

//delete password entry from firestore
Future<void> deletePassword(String id, FirebaseFirestore firestore, String userId) async{
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  if (userCollection.exists) {
    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;
    userData['groups'].forEach((key, value) {
      if (value.containsKey(id)) {
        value.remove(id);
        firestore.collection('users').doc(userId).update({
          'groups.$key': value,
        });
      }
    });
  } else {
    throw Exception('User not found');
  }
}

//update password entry in firestore
Future<void> updatePassword(String id, String title, String username, String cryptPassword, String note, String group, FirebaseFirestore firestore, String userId) async {
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  if (userCollection.exists) {
    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;
    if ((userData['groups'] ?? {}).containsKey(group)) {
      if ((userData['groups.$group'] ?? {}).containsKey(id)) {
        Map<String, String> password = {
          'title': title,
          'username': username,
          'password': cryptPassword,
          'Note': note,
        };
        await firestore.collection('users').doc(userId).update({
          'groups.$group.$id': password,
        });
      } else {
        throw Exception('Entry not found');
      }
    } else {
      throw Exception('Group not found');
    }
  } else {
    throw Exception('User not found');
  }
}

Future<void> addGroup(String group, FirebaseFirestore firestore, String userId) async {
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  if (userCollection.exists) {
    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;
    if (!(userData['groups'] ?? {}).containsKey(group)) {
      await firestore.collection('users').doc(userId).update({
        'groups.$group': {},
      });
    } else {
      throw Exception('Group already exists');
    }
  } else {
    throw Exception('User not found');
  }
}

Future<void> deleteGroup(String group, FirebaseFirestore firestore, String userId) async {
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  if (userCollection.exists) {
    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;
    if ((userData['groups'] ?? {}).containsKey(group)) {
      if (!(userData['groups'].length == 1)) {
        userData['groups'].remove(group);
        await firestore.collection('users').doc(userId).update({
          'groups': userData['groups'],
      });
      } else {
        throw Exception('Cannot delete last group');
      }

    } else {
      throw Exception('Group not found');
    }
  } else {
    throw Exception('User not found');
  }
}
