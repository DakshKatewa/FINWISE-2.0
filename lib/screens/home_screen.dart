import 'package:budgettraker/core/themes/app_colors.dart';
import 'package:budgettraker/widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/hero_card.dart';
import '../widgets/transactions_cards.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isLogoutLoading = false;

  logOut() async {
    setState(() {
      isLogoutLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const LoginView())),
      );
    }
    setState(() {
      isLogoutLoading = false;
    });
  }

  final userId = FirebaseAuth.instance.currentUser!.uid;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        username = userDoc['username'] ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3ED),
        title: Text("Hello ${username ?? ''}"),
      ),
      drawer: const AppDrawer(), // ← Use the drawer here
      body: SingleChildScrollView(
        child: Column(
          children: [HeroCard(userId: userId), const TransactionsCard()],
        ),
      ),
    );
  }
}
