import 'package:budgettraker/screens/insights_screen.dart';
import 'package:budgettraker/screens/reports_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    HomeScreen(),
    TransactionScreen(),
    InsightsScreen(),
    ReportsScreen(),
  ];

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        content: AddTransactionForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 👈 this makes FAB overlap nicely on navbar
      body: pageViewList[currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade900,
        shape: const CircleBorder(), // 👈 makes sure FAB is perfectly circular
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          //color: Color(0xFFF5F5F5), // 👈 light grey color matching app
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
    );
  }
}
