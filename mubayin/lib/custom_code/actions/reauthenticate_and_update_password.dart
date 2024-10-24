// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

import 'package:firebase_auth/firebase_auth.dart';

Future<String> reauthenticateAndUpdatePassword(
    String oldPassword, String newPassword) async {
  try {
    User user = FirebaseAuth.instance.currentUser!;
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    // Re-authenticate the user
    await user.reauthenticateWithCredential(credential);

    // If re-authentication is successful, update the password
    await user.updatePassword(newPassword);

    return "success"; // Return success message
  } catch (error) {
    if (error is FirebaseAuthException && error.code == 'wrong-password') {
      return "wrong-password"; // Return wrong password error
    } else {
      return "error"; // Return general error message
    }
  }
}
