import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import '../screens/dashboard.dart';

class Db {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  addUser(data, userId, context) async {
    // final userId = FirebaseAuth.instance.currentUser!.uid;
    await users
        .doc(userId)
        .set(data)
        .then((value) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: ((context) => const Dashboard())),
          );
        })
        .catchError((error) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Sign up Failed"),
                content: Text(error.toString()),
              );
            },
          );
        });
  }
}
