import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './encrypt/aes.dart';

Future<void> changePassword(BuildContext context, String oldPassword, String newPassword) async {
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

        // update all crypted instances in the database
        await db.collection("groups").get().then((groupSnapshot) async {
          for (var groupDoc in groupSnapshot.docs) {
            // Access subgroups for each group
            await db.collection("groups").doc(groupDoc.id).collection("subgroups").get().then((subgroupSnapshot) async {
              for (var subgroupDoc in subgroupSnapshot.docs) {
                // Access instances for each subgroup
                await db.collection("groups")
                    .doc(groupDoc.id)
                    .collection("subgroups")
                    .doc(subgroupDoc.id)
                    .collection("instances")
                    .get()
                    .then((instanceSnapshot) async {
                  for (var instanceDoc in instanceSnapshot.docs) {
                    // Retrieve, decrypt, and re-encrypt the password
                    var oldPassword = instanceDoc.data()["password"]; // Assuming the field is "password"
                    if (oldPassword != null) {
                      try {
                        String decrypted = await MyEncrypt.decrypt(oldPassword, instanceDoc.data()["password"]);
                        String encrypted = await MyEncrypt.encrypt(newPassword, decrypted);

                        // Update the encrypted password back in the database
                        await db.collection("groups")
                            .doc(groupDoc.id)
                            .collection("subgroups")
                            .doc(subgroupDoc.id)
                            .collection("instances")
                            .doc(instanceDoc.id)
                            .update({"password": encrypted});
                      } catch (e) {
                        print("Error processing password for instance ${instanceDoc.id}: $e");
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

        // Update password if re-authentication is successful
        await user.updatePassword(newPassword);
        var snackbar = const SnackBar(
          content: Text("Passphrase updated"),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.of(context).pop();
        //TODO add page redirect
        Navigator.pushReplacementNamed(context, '');
      } catch (e) { 
        print("Error : $e");
        var snackbar = const SnackBar(
            content: Text("Old password is incorrect!"),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.of(context).pop();

      }
    }

  }
