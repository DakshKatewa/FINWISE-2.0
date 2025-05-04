import 'package:budgettraker/screens/insights_screen.dart';
import 'package:budgettraker/screens/reports_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/navbar.dart' show NavBar;
import 'home_screen.dart';
import 'transaction_screen.dart' show TransactionScreen;
import '../widgets/add_transacetion_form.dart' show AddTransactionForm;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var isLogoutLoading = false;
  int currentIndex = 0;
  var pageViewList = [
    const HomeScreen(),
    const TransactionScreen(),
    const InsightsScreen(),
    const ReportsScreen(),
  ];

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(content: AddTransactionForm()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pageViewList[currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade900,
        shape: const CircleBorder(),
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: NavBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (int value) {
            setState(() {
              currentIndex = value;
            });
          },
        ),
      ),
      resizeToAvoidBottomInset: false, // Add this line here
    );
  }
}
