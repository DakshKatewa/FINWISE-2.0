import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _budgetController = TextEditingController();
  int monthlyBudget = 0;
  int totalSpentThisMonth = 0;

  @override
  void initState() {
    super.initState();
    fetchBudgetAndExpenses();
  }

  Future<int> fetchTotalSpentThisMonth() async {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final currentMonth = DateFormat('MMM y').format(now);

    if (user != null) {
      final transactionsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .where('monthyear', isEqualTo: currentMonth)
              .where('type', isEqualTo: 'debit')
              .get();

      int spent = transactionsSnapshot.docs.fold(0, (sum, doc) {
        return sum + (doc['amount'] as int);
      });

      return spent;
    }
    return 0;
  }

  Future<void> fetchBudgetAndExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final currentMonth = "${DateFormat('MMM y').format(now)}";

    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      int budget = (userDoc.data()?['monthlyBudget'] ?? 0) as int;

      final transactionsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .where('monthyear', isEqualTo: currentMonth)
              .where('type', isEqualTo: 'debit')
              .get();

      int spent = transactionsSnapshot.docs.fold(0, (sum, doc) {
        return sum + (doc['amount'] as int);
      });

      setState(() {
        monthlyBudget = budget;
        totalSpentThisMonth = spent;
      });
    }
  }

  Future<void> updateBudget() async {
    int newBudget = int.tryParse(_budgetController.text) ?? 0;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'monthlyBudget': newBudget},
      );

      // 🛠 After setting the new budget, fetch latest spent
      int spent = await fetchTotalSpentThisMonth();

      setState(() {
        monthlyBudget = newBudget;
        totalSpentThisMonth = spent;
      });

      _budgetController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentUsed =
        monthlyBudget > 0 ? totalSpentThisMonth / monthlyBudget : 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Monthly Budget", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          LinearPercentIndicator(
            lineHeight: 14.0,
            percent: percentUsed.clamp(0, 1),
            backgroundColor: Colors.grey.shade300,
            progressColor: Colors.blueAccent,
            center: Text(
              "${(percentUsed * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 12.0, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text("Spent ₹$totalSpentThisMonth out of ₹$monthlyBudget"),

          const SizedBox(height: 24),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Set Monthly Budget",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: updateBudget,
            child: const Text("Update Budget"),
          ),
        ],
      ),
    );
  }
}
