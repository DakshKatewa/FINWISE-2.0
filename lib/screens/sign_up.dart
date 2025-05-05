import 'package:budgettraker/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/appvalidator.dart';
import 'login_screen.dart';

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
  }

  var appValidator = AppValidator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80.0),
                const SizedBox(
                  width: 250,
                  child: Text(
                    "Create new Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50.0),
                TextFormField(
                  controller: _userNameController,
                  style: const TextStyle(color: Color.fromARGB(246, 8, 8, 8)),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Username", Icons.person),
                  validator: appValidator.validateUsername,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Color.fromARGB(246, 8, 8, 8)),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Email", Icons.email),
                  validator: appValidator.validateEmail,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: Color.fromARGB(246, 8, 8, 8)),
                  keyboardType: TextInputType.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Phone number", Icons.call),
                  validator: appValidator.validatePhoneNumber,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Color.fromARGB(246, 8, 8, 8)),
                  keyboardType: TextInputType.visiblePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _buildInputDecoration("Password", Icons.lock),
                  validator: appValidator.validatePassword,
                  obscureText: true,
                ),
                const SizedBox(height: 40.0),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      isLoader ? print("Loading") : _submitForm();
                    },
                    child:
                        isLoader
                            ? const Center(child: CircularProgressIndicator())
                            : const Text(
                              "Create",
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.onPrimary,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 5.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                    );
                  },
                  child: const Text(
                    "Already an user? Login",
                    style: TextStyle(color: AppColors.textColor, fontSize: 12),
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
      fillColor: AppColors.surface,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0x35949494)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      filled: true,
      labelStyle: const TextStyle(color: Color.fromARGB(53, 65, 65, 65)),
      labelText: label,
      suffixIcon: Icon(suffixIcon, color: AppColors.iconColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}
