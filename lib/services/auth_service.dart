import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/dashboard.dart';
import 'db.dart' show Db;

class AuthService {
  var db = Db();
  Future<void> createUser(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: data['email'].toString(),
            password: data['password'].toString(),
          );

      String userId = userCredential.user!.uid;
      data["id"] = userId;

      await db.addUser(data, userId, context);
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, "Firebase Auth Error: ${e.code}", e.message);
    } on FirebaseException catch (e) {
      _showErrorDialog(context, "Firebase Error", e.message);
    } catch (e, stackTrace) {
      _showErrorDialog(context, "Unexpected Error", e.toString());
      debugPrint(
        "Error: $e\nStack Trace: $stackTrace",
      ); // Logs detailed error in console
    }
  }

  void _showErrorDialog(BuildContext context, String title, String? message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message ?? "An unknown error occurred."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  login(data, context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const Dashboard())),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Login Error"),
            content: Text(e.toString()),
          );
        },
      );
    }
  }
}
