import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:budgettracker/core/constants/app_constants.dart';
import '../core/constants/asset_constants.dart';
import '../core/themes/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set system overlay style to match green theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
  await Future.delayed(const Duration(seconds: 6));
  
  if (mounted) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in, navigate to AuthGate
      Navigator.pushReplacementNamed(context, '/authGate');
    } else {
      // User is not signed in, navigate to SignupPage
      Navigator.pushReplacementNamed(context, '/signupView');
    }
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
        decoration: const BoxDecoration(
          color: AppColors.mainGreen,
          //borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Finance Buddy',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 1.2,
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
