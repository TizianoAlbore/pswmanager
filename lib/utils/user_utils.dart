import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pw_frontend/utils/encrypt/aes.dart';

//add user to firestore
Future<void> addUser(userCredential, firestore, emailController) async {
  String userId = userCredential.user!.uid;

  // each group has a map of IDs linked to the passwords details
  Map<String, Map<String, Map<String, String>>> groups = {
    'General': {},
  };
  //each totp entry has a map of IDs linked to the totp details
  Map<String, Map<String, String>> totps = {};

  await firestore.collection('users').doc(userId).set({
    'email': emailController.text.trim(),
    'groups': groups,
    'totps': totps,
  });
}

Future<Map<String, String>> getTotpDetails(FirebaseFirestore firestore, String userId, String id) async {
  Map<String, String> totpDetail = {};
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  if (userCollection.exists) {
    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;
    if ((userData['totps'] ?? {}).containsKey(id)) {
      totpDetail = userData['totps.$id'];
    } else {
      throw Exception('ID not found');
    }
  } else {
    throw Exception('User not found');
  }
  return totpDetail;
}

Future<void> addTotp(FirebaseFirestore firestore, String userId, String name, String service, int period, int digits, String secret) async {
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  if (userCollection.exists) {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, dynamic> totp = {
      'name': name,
      'service': service,
      'secret': secret,
      'period': period,
      'digits': digits,
    };

    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;

    if (!(userData['totps'] ?? {}).containsKey(id)) {
      await firestore.collection('users').doc(userId).update({
        'totps.$id': totp,
      });
    } else {
      throw Exception('ID already exists');
    }
  } else {
    throw Exception('User not found');
  }
}

Future<void> deleteTotp(FirebaseFirestore firestore, String userId, String id) async {
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  if (userCollection.exists) {
    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;
    if (userData['totps'].containsKey(id)) {
      userData['totps'].remove(id);
      await firestore.collection('users').doc(userId).update({
        'totps': userData['totps'],
      });
    } else {
      throw Exception('ID not found');
    }
  } else {
    throw Exception('User not found');
  }
}

Future<List<String>> getTotp(FirebaseFirestore firestore, String userId) async {
  List<String> totpEntries = [];
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  if (userCollection.exists) {
    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;
    userData['totps'].forEach((key, value) {
      totpEntries.add(value['title']);
    });
  } else {
    throw Exception('User not found');
  }
  return totpEntries;
}
Future<Map<String, dynamic>> getUser(FirebaseFirestore firestore, String userId) async {
  Map<String, dynamic> data = {};
  await firestore.collection('users').doc(userId).get().then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      data = documentSnapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('User not found');
    }
  });
  return data;
}

Future<List<String>> getGroups(FirebaseFirestore firestore, String userId) async {
  List<String> groups = [];
  await firestore.collection('users').doc(userId).get().then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      data['groups'].forEach((key, value) {
        groups.add(key.toString());
      });
    } else {
      throw Exception('User not found');
    }
  });
  return groups;
}

Future<Map<String, String>> getPasswordsFromGroup(FirebaseFirestore firestore, String userId, String group) async {
  Map<String, String> passwords = {};
  await firestore.collection('users').doc(userId).get().then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      (data['groups'][group] ?? {} ).forEach((key, value) {
        passwords[key] = value['title'];
      });
    }else {
      throw Exception('User not found');
    }
  });
  return passwords;
}

Future<Map<String, String>> getPasswordDetail(FirebaseFirestore firestore, String userId, String group, String id) async {
  Map<String, String> passwdDetail = {};
  DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();
  if(userCollection.exists){
    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;

    if ((userData['groups'] ?? {}).containsKey(group)) {
      //check if id exists, then get details
      if ((userData['groups.$group'] ?? {}).containsKey(id)) {
        passwdDetail = userData['groups.$group.$id'];
      } else {
        //if id already exists throw exception
        throw Exception('Password ID not found');
      }
    }
  }else {
    throw Exception('User not found');
  }
  return passwdDetail;
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

Future<void> updatePassword(
  String id,
  String title,
  String username,
  String cryptPassword,
  String note,
  String group,
  FirebaseFirestore firestore,
  String userId,
) async {
  try {
    // Recupera la collezione utente
    DocumentSnapshot userCollection = await firestore.collection('users').doc(userId).get();

    if (!userCollection.exists) {
      throw Exception('User not found');
    }

    Map<String, dynamic> userData = userCollection.data() as Map<String, dynamic>;

    // Verifica l'esistenza del gruppo
    if (!(userData['groups'] ?? {}).containsKey(group)) {
      throw Exception('Group not found');
    }

    // Verifica l'esistenza dell'entry della password
    if (!(userData['groups'][group] ?? {}).containsKey(id)) {
      throw Exception('Entry not found');
    }

    // Aggiorna i dettagli della password
    Map<String, String> password = {
      'title': title,
      'username': username,
      'password': cryptPassword,
      'Note': note,
    };

    await firestore.collection('users').doc(userId).update({
      'groups.$group.$id': password,
    });

  } catch (e) {
    rethrow; // Propaga l'errore
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
