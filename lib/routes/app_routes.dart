import 'package:budgettraker/screens/sign_up.dart';
import 'package:budgettraker/screens/splash.dart';
import 'package:budgettraker/widgets/auth_gate.dart';
import 'package:flutter/widgets.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes(){
    return {
      '/': (context) => const SplashScreen(),
      '/authGate' : (context) =>const AuthGate(),
      '/signupView' : (context) =>const SignUpView()
    };
  }
}
