// import 'package:budgettraker/firebase_options.dart';
import 'package:budgettraker/core/themes/app_themes.dart';
import 'package:budgettraker/routes/app_routes.dart';
import 'package:budgettraker/screens/sign_up.dart';
import 'package:budgettraker/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //print("fff");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //print("ffdddf");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tacker',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler:const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
      //   useMaterial3: true,
      // ),
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      
      // home: FirebaseAuth.instance.currentUser == null ? SignUpView() : const AuthGate(),
      initialRoute: '/',
      routes: AppRoutes.getRoutes(),
    );
  }
}
