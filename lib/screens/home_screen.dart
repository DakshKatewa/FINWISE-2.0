import 'package:budgettraker/core/themes/app_colors.dart';
import 'package:budgettraker/widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
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
  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // loading cached data first
    final hasCachedData = await UserDataProvider.instance.loadCachedData();

    if (!hasCachedData) {
      // If no cached data, refreshing from Firebase
      await UserDataProvider.instance.refreshData();
    }

    //real time listeners for future updates
    UserDataProvider.instance.setupListeners(userId);

    if (mounted) {
      setState(() {
        isInitialized = true;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: UserDataProvider.instance,
      child: Consumer<UserDataProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.background,
              title: Text(
                "Hello ${provider.username}",
                style: const TextStyle(color: AppColors.textColor),
              ),
            ),
            drawer: const AppDrawer(),
            body:
                provider.isLoading && !isInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: () => provider.refreshData(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            HeroCard(userId: userId),
                            const TransactionsCard(),
                          ],
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }
}
