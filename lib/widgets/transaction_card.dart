import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../utils/icons_list.dart';

class TransactionCard extends StatelessWidget {
  TransactionCard({super.key, required this.data, this.onDeleted});
  final dynamic data;
  final VoidCallback? onDeleted;

  final appIcons = AppIcons();

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
              offset: const Offset(0, 10),
              color: Colors.grey.withValues(alpha: 0.09),
              blurRadius: 10.0,
              spreadRadius: 4.0,
            ),
          ],
        ),
        child: ListTile(
          minVerticalPadding: 10,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          leading: SizedBox(
            width: 70,
            height: 100,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color:
                    data['type'] == 'credit'
                        ? Color(0xffA0C4A8).withOpacity(0.3)
                        : Color(0xFF6B7280).withOpacity(0.2),
              ),
              child: Center(
                child: FaIcon(
                  appIcons.getExpenseCategoryIcons('${data['category']}'),
                  color:
                      data['type'] == 'credit'
                          ? const Color.fromARGB(255, 63, 120, 65)
                          : const Color.fromARGB(255, 187, 61, 52),
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
                  color:
                      data['type'] == 'credit'
                          ? const Color.fromARGB(255, 63, 120, 65)
                          : const Color.fromARGB(255, 187, 61, 52),
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
                  const Text(
                    "Balance",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    "₹${data['remainingAmount']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              Text(formatedDate, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete,
              color: Color.fromARGB(255, 204, 84, 73),
            ),
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
            title: const Text('Delete Transaction'),
            content: const Text(
              'Are you sure you want to delete this transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteTransaction(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
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

      await transactionRef.delete();

      final remainingTransactions =
          await userRef.collection('transactions').get();
      if (remainingTransactions.docs.isEmpty) {
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

        double remainingAmount = totalCredit - totalDebit;

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted successfully')),
      );

      onDeleted?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $e')),
      );
    }
  }
}
