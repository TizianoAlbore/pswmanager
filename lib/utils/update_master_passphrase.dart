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
      return;
    }

    // update all crypted instances in the database
    print("Re-encrypting entries with new masterpassword...");
    try {
      // Recupera i dati dell'utente
      DocumentSnapshot userDoc =
          await db.collection('users').doc(user.uid).get();
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
              return;
            }
          } else {
            print("No password found for $group->$id");
          }
        }
      }

      print("Re-encryption completed.");
    } catch (e) {
      print("Error during re-encryption: $e");
      return;
    }

    // update TOTPs
    print("Re-encrypting TOTP secrets with new masterpassword...");
    try {
      // Recupera i dati dell'utente
      DocumentSnapshot userDoc =
          await db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception("User not found");
      }

      // Converte i dati in una mappa per accedere ai TOTP
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> totps = userData['totps'] ?? {};

      for (String id in totps.keys) {
        Map<String, dynamic> totpData = totps[id];
        if (totpData.containsKey('secret')) {
          try {
            // Decripta il secret esistente con la vecchia master password
            String decryptedSecret =
                await MyEncrypt.decrypt(oldPassword, totpData['secret']);

            // Cripta il secret con la nuova master password
            String reEncryptedSecret =
                await MyEncrypt.encrypt(newPassword, decryptedSecret);

            // Aggiorna il secret criptato nel database
            await db.collection('users').doc(user.uid).update({
              'totps.$id.secret': reEncryptedSecret,
            });

            print("TOTP secret for $id updated successfully.");
          } catch (e) {
            print("Failed to re-encrypt TOTP secret for $id: $e");
            return;
          }
        } else {
          print("No secret found for TOTP $id");
        }
      }

      print("Re-encryption of TOTP secrets completed.");
    } catch (e) {
      print("Error during re-encryption: $e");
      return;
    }

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
      return;
    }
  }
}
