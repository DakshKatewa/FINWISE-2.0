import 'package:budgettraker/core/themes/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

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
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    fetchBudgetAndExpenses(_selectedMonth!);
  }

  Future<void> fetchBudgetAndExpenses(DateTime month) async {
    final user = FirebaseAuth.instance.currentUser;
    final currentMonthFormatted = DateFormat('MMM y').format(month);

    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final budgetValue =
          userDoc.data()?['budgets']?[currentMonthFormatted] ??
          userDoc.data()?['monthlyBudget'] ??
          0;
      final int budget = _parseNumber(budgetValue);

      final transactionsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .where('monthyear', isEqualTo: currentMonthFormatted)
              .where('type', isEqualTo: 'debit')
              .get();

      int spent = transactionsSnapshot.docs.fold(0, (sum, doc) {
        return sum + _parseNumber(doc['amount']);
      });

      setState(() {
        monthlyBudget = budget;
        totalSpentThisMonth = spent;
      });
    }
  }

  int _parseNumber(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1, 12),
    );
    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
        fetchBudgetAndExpenses(_selectedMonth!);
      });
    }
  }

  Future<void> updateBudget() async {
    int newBudget = int.tryParse(_budgetController.text) ?? 0;
    final user = FirebaseAuth.instance.currentUser;
    final currentMonthFormatted = DateFormat('MMM y').format(_selectedMonth!);

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'budgets.$currentMonthFormatted': newBudget},
      );

      _budgetController.clear();
      fetchBudgetAndExpenses(_selectedMonth!);
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

      final budgetsMap =
          userDoc.data()?['budgets'] as Map<String, dynamic>? ?? {};

      List<Map<String, dynamic>> tempHistory = [];

      for (var entry in budgetsMap.entries) {
        final String month = entry.key;
        final int budget = _parseNumber(entry.value);

        final transactionsSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('transactions')
                .where('monthyear', isEqualTo: month)
                .where('type', isEqualTo: 'debit')
                .get();

        final int spent = transactionsSnapshot.docs.fold(0, (sum, doc) {
          return sum + _parseNumber(doc['amount']);
        });

        tempHistory.add({'month': month, 'budget': budget, 'spent': spent});
      }

      tempHistory.sort(
        (a, b) => DateFormat(
          'MMM y',
        ).parse(a['month']).compareTo(DateFormat('MMM y').parse(b['month'])),
      );

      setState(() {
        monthlyHistory = tempHistory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double percentUsed =
        monthlyBudget > 0
            ? totalSpentThisMonth / monthlyBudget.toDouble()
            : 0.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Monthly Budget",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _selectMonth(context),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMM y').format(_selectedMonth!),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 20.0,
              percent: percentUsed.clamp(0, 1),
              backgroundColor: Colors.grey.shade300,
              progressColor: AppColors.buttonColor,
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
                labelText:
                    "Set Budget for ${DateFormat('MMM y').format(_selectedMonth!)}",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: updateBudget,
                    icon: const Icon(Icons.save_alt),
                    label: const Text("Update Budget"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await fetchMonthlyHistory();
                      setState(() => showHistory = !showHistory);
                    },
                    icon: Icon(
                      showHistory ? Icons.visibility_off : Icons.history,
                    ),
                    label: Text(showHistory ? "Hide History" : "Show History"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
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
                            double percent =
                                entry['budget'] > 0
                                    ? (entry['spent'] / entry['budget']).clamp(
                                      0.0,
                                      1.0,
                                    )
                                    : 0.0;

                            Color progressColor;
                            if (percent < 0.5) {
                              progressColor = Colors.green;
                            } else if (percent < 0.9) {
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
                                      value: percent,
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
                          }).toList(),
                        ],
                      )
                      : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
