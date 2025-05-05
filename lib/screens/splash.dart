import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/asset_constants.dart';
import '../core/themes/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_data_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _prefetchUserData(user.uid);
    }

    if (!_isDataLoaded) {
      await Future.delayed(const Duration(seconds: 1));
    }

    if (mounted) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/authGate');
      } else {
        Navigator.pushReplacementNamed(context, '/signupView');
      }
    }
  }

  Future<void> _prefetchUserData(String userId) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final transactionsSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('transactions')
                .orderBy('timestamp', descending: true)
                .limit(20)
                .get();

        final transactions =
            transactionsSnapshot.docs.map((doc) => doc.data()).toList();

        await UserDataProvider.initialize(
          userData: userData,
          transactions: transactions,
          username: userData['username'] ?? 'User',
        );

        setState(() {
          _isDataLoaded = true;
        });
      }
    } catch (e) {
      print('Error prefetching data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430.0,
        height: 932.0,
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AssetConstants.darklogoPath,
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'FinWise',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Finance Buddy',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.darkGreen,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isDataLoaded)
                    const Text(
                      'Data loaded',
                      style: TextStyle(fontSize: 14, color: Colors.green),
                    )
                  else
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.darkGreen,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
