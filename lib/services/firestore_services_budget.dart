import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  static Future<void> setMonthlyBudget(int budget) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'monthlyBudget': budget},
      );
    }
  }

  static Future<int> getCurrentMonthSpent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final now = DateTime.now();
      String monthyear = DateFormat('MMM y').format(now);

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .where('monthyear', isEqualTo: monthyear)
              .where('type', isEqualTo: 'debit')
              .get();

      int totalSpent = 0;
      for (var doc in snapshot.docs) {
        totalSpent += (doc['amount'] as num).toInt();
      }
      return totalSpent;
    }
    return 0;
  }
}
