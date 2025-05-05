import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/expense_insights.dart';
import '../widgets/time_line_month.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String monthYear = "";

  @override
  void initState() {
    super.initState();
    monthYear = DateFormat('MMM y').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          TimeLineMonth(
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  monthYear = value;
                });
              }
            },
          ),
          const SizedBox(height: 10),
          Expanded(child: ExpenseInsights(selectedMonth: monthYear)),
        ],
      ),
    );
  }
}
