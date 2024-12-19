import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './encrypt/aes.dart';

Future<void> changePassword(
    BuildContext context, String oldPassword, String newPassword) async {
  // Get the current user
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore db = FirebaseFirestore.instance;

  if (user != null && user.email != null) {
    try {
      // Re-authenticate the user with the old password
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(cred);
      print("reauthenticated successfully");
    } catch (e) {
      print("Error : $e");
      var snackbar = const SnackBar(
        content: Text("Old password is incorrect!"),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
    
    // update all crypted instances in the database
    print("Re-encrypting entries with new masterpassword...");
    try {
    // Recupera i dati dell'utente
    DocumentSnapshot userDoc = await db.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      throw Exception("User not found");
    }

    // Converte i dati in una mappa per accedere ai gruppi
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    Map<String, dynamic> groups = userData['groups'] ?? {};

    for (String group in groups.keys) {
      // Per ogni gruppo, itera sugli ID delle password
      Map<String, dynamic> passwords = groups[group] ?? {};
      for (String id in passwords.keys) {
        Map<String, dynamic> passwordData = passwords[id];
        if (passwordData.containsKey('password')) {
          try {
            // Decripta la password esistente con la vecchia master password
            String decryptedPassword = await MyEncrypt.decrypt(
                oldPassword, passwordData['password']);

            // Cripta la password con la nuova master password
            String reEncryptedPassword =
                await MyEncrypt.encrypt(newPassword, decryptedPassword);

            // Aggiorna la password criptata nel database
            await db.collection('users').doc(user.uid).update({
              'groups.$group.$id.password': reEncryptedPassword,
            });

            print("Password for $group->$id updated successfully.");
          } catch (e) {
            print("Failed to re-encrypt password for $group->$id: $e");
          }
        } else {
          print("No password found for $group->$id");
        }
      }
    }

    print("Re-encryption completed.");
  } catch (e) {
    print("Error during re-encryption: $e");
  }

    /*
    try {
      await db.collection("groups").get().then((groupSnapshot) async {
        for (var groupDoc in groupSnapshot.docs) {
          // Access subgroups for each group
          print(groupDoc.id);
          await db
              .collection("groups")
              .doc(groupDoc.id)
              .collection("subgroups")
              .get()
              .then((subgroupSnapshot) async {
            for (var subgroupDoc in subgroupSnapshot.docs) {
              // Access instances for each subgroup
              print(subgroupDoc.id);
              await db
                  .collection("groups")
                  .doc(groupDoc.id)
                  .collection("subgroups")
                  .doc(subgroupDoc.id)
                  .collection("instances")
                  .get()
                  .then((instanceSnapshot) async {
                for (var instanceDoc in instanceSnapshot.docs) {
                  // Retrieve, decrypt, and re-encrypt the password
                  var oldPassword = instanceDoc
                      .data()["password"]; // Assuming the field is "password"
                  if (oldPassword != null) {
                    try {
                      String decrypted = await MyEncrypt.decrypt(
                          oldPassword, instanceDoc.data()["password"]);
                      String encrypted =
                          await MyEncrypt.encrypt(newPassword, decrypted);

                      // Update the encrypted password back in the database
                      await db
                          .collection("groups")
                          .doc(groupDoc.id)
                          .collection("subgroups")
                          .doc(subgroupDoc.id)
                          .collection("instances")
                          .doc(instanceDoc.id)
                          .update({"password": encrypted});
                    } catch (e) {
                      print(
                          "Error processing password for instance ${instanceDoc.id}: $e");
                    }
                  } else {
                    print("No password found for instance ${instanceDoc.id}");
                  }
                }
              });
            }
          });
        }
      });
      */

      // Update password if re-authentication is successful
      print("updating password...");
      try {
        await user.updatePassword(newPassword);
        print("Password updated successfully.");
        var snackbar = const SnackBar(
          content: Text("Password updated successfully."),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/dashboard');
      } catch (e) {
        print("Error : $e");
        var snackbar = const SnackBar(
          content: Text("Error updating password!"),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
  }
}
