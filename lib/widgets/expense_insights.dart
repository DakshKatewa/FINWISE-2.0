import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseInsights extends StatefulWidget {
  final String selectedMonth; // Expected format: "Apr 2025"

  const ExpenseInsights({super.key, required this.selectedMonth});

  @override
  State<ExpenseInsights> createState() => _ExpenseInsightsState();
}

class _ExpenseInsightsState extends State<ExpenseInsights> {
  late Future<Map<String, double>> _expensesFuture;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _expensesFuture = _fetchExpensesGroupedByCategory();
  }

  @override
  void didUpdateWidget(covariant ExpenseInsights oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
        _expensesFuture = _fetchExpensesGroupedByCategory();
      });
    }
  }

  Future<Map<String, double>> _fetchExpensesGroupedByCategory() async {
    try {
      print("Fetching data for month: ${widget.selectedMonth}");

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Error: Current user is null");
        setState(() {
          _hasError = true;
          _errorMessage = "User not logged in";
        });
        return {"No Data": 1.0};
      }

      DateTime parsedDate;
      try {
        parsedDate = DateFormat('MMM y').parse(widget.selectedMonth);
        print("Successfully parsed date: $parsedDate");
      } catch (e) {
        print("Error parsing date '${widget.selectedMonth}': $e");
        setState(() {
          _hasError = true;
          _errorMessage = "Invalid date format";
        });
        return {"Error": 1.0};
      }

      final monthYearFilter = DateFormat('MMM y').format(parsedDate);
      print("Using month/year filter: $monthYearFilter");

      QuerySnapshot snapshot;
      try {
        snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('transactions')
                .where('monthyear', isEqualTo: monthYearFilter)
                .get();

        print("Fetched ${snapshot.docs.length} documents");
      } catch (e) {
        print("Error querying Firestore: $e");
        setState(() {
          _hasError = true;
          _errorMessage = "Database query failed";
        });
        return {"Error": 1.0};
      }

      Map<String, double> categoryTotals = {};

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          String category = data['category'] as String? ?? 'Uncategorized';
          String type = data['type'] as String? ?? 'Unknown';
          double amount;
          if (data['amount'] is num) {
            amount = (data['amount'] as num).toDouble();
          } else {
            print("Warning: Invalid amount in document ${doc.id}");
            continue;
          }

          String displayCategory;
          if (type.isNotEmpty) {
            displayCategory =
                "$category (${type[0].toUpperCase()}${type.substring(1)})";
          } else {
            displayCategory = "$category (Unknown)";
          }

          print("Category: $displayCategory, Amount: $amount");
          categoryTotals[displayCategory] =
              (categoryTotals[displayCategory] ?? 0) + amount;
        } catch (e) {
          print("Error processing document ${doc.id}: $e");
        }
      }

      print("Final category totals: $categoryTotals");

      if (categoryTotals.isEmpty) {
        categoryTotals = {"No Data": 1.0};
      }

      return categoryTotals;
    } catch (e, stackTrace) {
      print("Error in _fetchExpensesGroupedByCategory: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
      return {"Error": 1.0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || _hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'An error occurred while fetching data.',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No data found.', style: TextStyle(fontSize: 16)),
          );
        }

        final data = snapshot.data!;
        final total = data.values.reduce((a, b) => a + b);

        final creditColors = [
          Colors.green[300]!,
          Colors.green[400]!,
          Colors.green[500]!,
          Colors.green[600]!,
          Colors.teal[400]!,
          Colors.teal[500]!,
        ];

        final debitColors = [
          Colors.red[300]!,
          Colors.red[400]!,
          Colors.red[500]!,
          Colors.red[600]!,
          Colors.orange[400]!,
          Colors.orange[500]!,
        ];

        Map<String, Color> categoryColors = {};
        int creditColorIndex = 0;
        int debitColorIndex = 0;

        for (var entry in data.entries) {
          final isCredit = entry.key.toLowerCase().contains('(credit)');
          final Color color =
              isCredit
                  ? creditColors[creditColorIndex++ % creditColors.length]
                  : debitColors[debitColorIndex++ % debitColors.length];
          categoryColors[entry.key] = color;
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            Text(
              "Transaction Distribution for ${widget.selectedMonth}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (data.containsKey("No Data"))
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No expense data found for this month",
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections:
                        data.entries.map((entry) {
                          final Color color = categoryColors[entry.key]!;
                          return PieChartSectionData(
                            color: color,
                            value: entry.value,
                            title: '',
                            radius: 80,
                            badgeWidget: null,
                            showTitle: false,
                          );
                        }).toList(),
                    sectionsSpace: 0, // Removed white lines
                    centerSpaceRadius: 40,
                    pieTouchData: PieTouchData(enabled: true),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 150),
                ),
              ),

            if (!data.containsKey("No Data"))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem("Credit", creditColors[0]),
                    const SizedBox(width: 20),
                    _buildLegendItem("Debit", debitColors[0]),
                  ],
                ),
              ),

            if (!data.containsKey("No Data"))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Transaction Details:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...data.entries.map((entry) {
                        final percentage = (entry.value / total) * 100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: categoryColors[entry.key],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key
                                      .replaceAll(' (Credit)', ' (Credit)')
                                      .replaceAll(' (Debit)', ' (Debit)'),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                "${percentage.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
