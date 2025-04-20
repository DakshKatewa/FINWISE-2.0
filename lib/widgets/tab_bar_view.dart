import 'package:flutter/material.dart';
import 'transaction_list.dart';

class TypeTabBar extends StatelessWidget {
  const TypeTabBar({
    super.key,
    required this.category,
    required this.monthYear,
    required this.onTransactionDeleted,
  });

  final String category;
  final String monthYear;
  final VoidCallback? onTransactionDeleted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: "Credit"),
                Tab(text: "Debit"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TransectionList(
                    category: category,
                    monthYear: monthYear,
                    type: 'credit',
                    onTransactionDeleted: onTransactionDeleted, // 👈 pass here
                  ),
                  TransectionList(
                    category: category,
                    monthYear: monthYear,
                    type: 'debit',
                    onTransactionDeleted: onTransactionDeleted, // 👈 and here
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
