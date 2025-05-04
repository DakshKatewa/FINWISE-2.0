import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import 'transaction_card.dart';

class TransactionsCard extends StatelessWidget {
  const TransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ],
          ),
          RecentTransactionsListOptimized(),
        ],
      ),
    );
  }
}

class RecentTransactionsListOptimized extends StatelessWidget {
  const RecentTransactionsListOptimized({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          // Show skeleton loading UI
          return _buildLoadingList();
        }

        if (provider.transactions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: Text('No transactions found.'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: provider.transactions.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return TransactionCard(
              data: provider.transactions[index],
              onDeleted: () {
                // Will be automatically updated via the Stream listener
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingList() {
    // Create a skeleton loading UI instead of just text
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 3, // Show 3 skeleton items
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 10),
                  color: Colors.grey.withOpacity(0.09),
                  blurRadius: 10.0,
                  spreadRadius: 4.0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Leading circle
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Container(
                        width: 150,
                        height: 14,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
                // Amount
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: 60,
                    height: 20,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
