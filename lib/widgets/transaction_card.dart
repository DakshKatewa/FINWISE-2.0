import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../utils/icons_list.dart';

class TransactionCard extends StatelessWidget {
  TransactionCard({super.key, required this.data});
  final dynamic data;

  var appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
    String formatedDate = DateFormat('d MMM hh:mma').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 10),
              color: Colors.grey.withOpacity(0.09),
              blurRadius: 10.0,
              spreadRadius: 4.0,
            ),
          ],
        ),
        child: ListTile(
          minVerticalPadding: 10,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          leading: Container(
            width: 70,
            height: 100,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color:
                    data['type'] == 'credit'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
              ),
              child: Center(
                child: FaIcon(
                  appIcons.getExpenseCategoryIcons('${data['category']}'),
                  color: data['type'] == 'credit' ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(child: Text('${data['title']}')),
              Text(
                "${data['type'] == 'credit' ? '+' : '-'} ₹${data['amount']}",
                style: TextStyle(
                  color: data['type'] == 'credit' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Balance",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Spacer(),
                  Text(
                    "₹${data['remainingAmount']}",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              Text(formatedDate, style: TextStyle(color: Colors.grey)),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Transaction'),
            content: Text('Are you sure you want to delete this transaction?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  await _deleteTransaction(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final transactionId = data['id'];
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid);
      final transactionRef = userRef
          .collection('transactions')
          .doc(transactionId);

      // Delete the transaction
      await transactionRef.delete();

      // Check if any transactions remain
      final remainingTransactions =
          await userRef.collection('transactions').get();
      if (remainingTransactions.docs.isEmpty) {
        // If no transactions left, reset everything to 0
        await userRef.update({
          'totalBalance': 0,
          'remainingAmount': 0,
          'totalIncome': 0,
          'totalExpense': 0,
          'totalCredit': 0,
          'totalDebit': 0,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        // Instead of adjusting the existing values, recalculate from scratch
        double totalBalance = 0;
        double totalIncome = 0;
        double totalExpense = 0;
        double totalCredit = 0;
        double totalDebit = 0;

        // Loop through all remaining transactions and calculate totals
        for (var doc in remainingTransactions.docs) {
          var transaction = doc.data();
          double amount =
              double.tryParse(transaction['amount'].toString()) ?? 0.0;

          if (transaction['type'] == 'credit') {
            totalCredit += amount;
            totalIncome += amount;
            totalBalance += amount;
          } else {
            totalDebit += amount;
            totalExpense += amount;
            totalBalance -= amount;
          }
        }

        // Calculate remaining amount
        double remainingAmount = totalCredit - totalDebit;

        // Update user document with recalculated values
        await userRef.update({
          'totalBalance': totalBalance,
          'totalIncome': totalIncome,
          'totalExpense': totalExpense,
          'totalCredit': totalCredit,
          'totalDebit': totalDebit,
          'remainingAmount': remainingAmount,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $e')),
      );
    }
  }
}
