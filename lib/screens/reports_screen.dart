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
  List<Map<String, dynamic>> monthlyHistory = [];
  bool showHistory = false;

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

      // ignore: avoid_types_as_parameter_names
      int spent = transactionsSnapshot.docs.fold(0, (sum, doc) {
        // Safely convert any numeric type to int
        final amount = doc['amount'];
        if (amount is int) {
          return sum + amount;
        } else if (amount is double) {
          return sum + amount.toInt();
        }
        return sum;
      });

      return spent;
    }
    return 0;
  }

  Future<void> fetchBudgetAndExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final currentMonth = DateFormat('MMM y').format(now);

    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      // Safely handle budget which could be int or double
      final budgetValue = userDoc.data()?['monthlyBudget'] ?? 0;
      int budget;
      if (budgetValue is int) {
        budget = budgetValue;
      } else if (budgetValue is double) {
        budget = budgetValue.toInt();
      } else {
        budget = 0;
      }

      final transactionsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .where('monthyear', isEqualTo: currentMonth)
              .where('type', isEqualTo: 'debit')
              .get();

      // Safely handle amount which could be int or double
      int spent = transactionsSnapshot.docs.fold(0, (sum, doc) {
        final amount = doc['amount'];
        if (amount is int) {
          return sum + amount;
        } else if (amount is double) {
          return sum + amount.toInt();
        }
        return sum;
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
    final now = DateTime.now();
    final currentMonth = DateFormat('MMM y').format(now);

    if (user != null) {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      await userDoc.update({
        'monthlyBudget': newBudget,
        'budgets.$currentMonth': newBudget,
      });

      fetchBudgetAndExpenses();
      _budgetController.clear();
    }
  }

  Future<void> fetchMonthlyHistory() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      Map<String, dynamic> budgetsMap =
          (userDoc.data()?['budgets'] ?? {}) as Map<String, dynamic>;

      List<Map<String, dynamic>> tempHistory = [];

      for (var entry in budgetsMap.entries) {
        String month = entry.key;
        // Safely convert budget to int
        int budget;
        if (entry.value is int) {
          budget = entry.value;
        } else if (entry.value is double) {
          budget = (entry.value as double).toInt();
        } else {
          budget = 0;
        }

        final transactionsSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('transactions')
                .where('monthyear', isEqualTo: month)
                .where('type', isEqualTo: 'debit')
                .get();

        // Safely handle amount which could be int or double
        int spent = transactionsSnapshot.docs.fold(0, (sum, doc) {
          final amount = doc['amount'];
          if (amount is int) {
            return sum + amount;
          } else if (amount is double) {
            return sum + amount.toInt();
          }
          return sum;
        });

        tempHistory.add({'month': month, 'budget': budget, 'spent': spent});
      }

      tempHistory.sort((a, b) => a['month'].compareTo(b['month']));

      setState(() {
        monthlyHistory = tempHistory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convert to double for percentage calculation
    double percentUsed =
        monthlyBudget > 0 ? totalSpentThisMonth / monthlyBudget.toDouble() : 0;

    return SafeArea(
      // <-- Adds padding from top notch and sides
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Budget",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 20.0,
              percent: percentUsed.clamp(0, 1),
              backgroundColor: Colors.grey.shade300,
              progressColor: Colors.blueAccent,
              animation: true,
              animationDuration: 800,
              center: Text(
                "${(percentUsed * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 14.0, color: Colors.white),
              ),
              barRadius: const Radius.circular(8),
            ),
            const SizedBox(height: 12),
            Text(
              "Spent ₹$totalSpentThisMonth out of ₹$monthlyBudget",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Set Monthly Budget",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Row for smaller stylish buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: updateBudget,
                    icon: const Icon(Icons.save_alt),
                    label: const Text("Update Budget"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await fetchMonthlyHistory();
                      setState(() {
                        showHistory = !showHistory;
                      });
                    },
                    icon: Icon(
                      showHistory ? Icons.visibility_off : Icons.history,
                    ),
                    label: Text(showHistory ? "Hide History" : "Show History"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child:
                  showHistory
                      ? Column(
                        key: const ValueKey('historyList'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "History",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ...monthlyHistory.map((entry) {
                            // Convert to double for percentage calculation
                            double percentUsed =
                                entry['budget'] > 0
                                    ? (entry['spent'] /
                                            entry['budget'].toDouble())
                                        .clamp(0.0, 1.0)
                                    : 0.0;

                            Color progressColor;
                            if (percentUsed < 0.5) {
                              progressColor = Colors.green;
                            } else if (percentUsed < 0.9) {
                              progressColor = Colors.orange;
                            } else {
                              progressColor = Colors.red;
                            }

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry['month'],
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: percentUsed,
                                      backgroundColor: Colors.grey.shade300,
                                      color: progressColor,
                                      minHeight: 10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Spent ₹${entry['spent']} / ₹${entry['budget']}",
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      )
                      : const SizedBox(), // Empty space if not showing
            ),
          ],
        ),
      ),
    );
  }
}
