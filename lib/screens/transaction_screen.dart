import 'package:budgettraker/widgets/expense_insights.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/category_list.dart';
import '../widgets/tab_bar_view.dart';
import '../widgets/time_line_month.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  var category = "All";
  var monthYear = "";

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    monthYear = DateFormat('MMM y').format(now);
  }

  void refreshState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),
      body: Column(
        children: [
          TimeLineMonth(
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  monthYear = value;
                });
              }
            },
          ),
          CategoryList(
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  category = value;
                });
              }
            },
          ),
          Flexible(
            flex: 2, // Gives more space to the chart
            child: ExpenseInsights(selectedMonth: monthYear),
          ),
          // Replace Expanded with Flexible
          Flexible(
            child: TypeTabBar(
              category: category,
              monthYear: monthYear,
              onTransactionDeleted: refreshState,
            ),
          ),
        ],
      ),
    );
  }
}
