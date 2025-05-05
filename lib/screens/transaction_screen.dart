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
      appBar: AppBar(
        title: const Text("Expenses"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline month selector
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: TimeLineMonth(
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      monthYear = value;
                    });
                  }
                },
              ),
            ),

            // Category selector
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: CategoryList(
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      category = value;
                    });
                  }
                },
              ),
            ),

            // Main content area
            Expanded(
              child: TypeTabBar(
                category: category,
                monthYear: monthYear,
                onTransactionDeleted: refreshState,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
