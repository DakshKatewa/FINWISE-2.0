import 'package:budgettraker/core/themes/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/appvalidator.dart';
import 'login_screen.dart';

// ignore_for_file: prefer_const_constructors
class SignUpView extends StatefulWidget {
 const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _userNameController = TextEditingController();

  final _emailController = TextEditingController();

  final _phoneController = TextEditingController();

  final _passwordController = TextEditingController();

  var authService = AuthService();
  var isLoader = false;

  Future<void> _submitForm() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isLoader = true;
        });

        var data = {
          "username": _userNameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "phone": _phoneController.text,
          'remainingAmount': 0,
          'totalCredit': 0,
          'totalDebit': 0,
        };

        await authService.createUser(data, context);
      }
    } finally {
      setState(() {
        isLoader = false;
      });
    }

    // ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
    //   const SnackBar(content: Text('Form submitted successfully')),
    // );
  }

  var appValidator = AppValidator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFF252634),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 80.0),
                SizedBox(
                  width: 250,
                  child: Text(
                    "Create new Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 50.0),
                TextFormField(
                  controller: _userNameController,
                  style: TextStyle(color: Colors.white),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Username", Icons.person),
                  validator: appValidator.validateUsername,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.white),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Email", Icons.email),
                  validator: appValidator.validateEmail,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  style: TextStyle(color: AppColors.darkGreen),
                  keyboardType: TextInputType.visiblePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Phone number", Icons.call),
                  validator: appValidator.validatePhoneNumber,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: AppColors.darkGreen),
                  keyboardType: TextInputType.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Password", Icons.lock),
                  validator: appValidator.validatePassword,
                  obscureText: true,
                ),
                SizedBox(height: 40.0),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainGreen
                    ),
                    onPressed: () {
                      isLoader ? print("Loading") : _submitForm();
                    },
                    child:
                        isLoader
                            ? Center(child: CircularProgressIndicator())
                            : Text(
                              "Create",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                SizedBox(height: 5.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginView()),
                    );
                  },
                  child: Text(
                    "Already an user? Login",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
      fillColor: AppColors.lightGreen,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0x35949494)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      filled: true,
      labelStyle: TextStyle(color: Colors.white),
      labelText: label,
      suffixIcon: Icon(suffixIcon, color: Color(0xFF949494)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}
