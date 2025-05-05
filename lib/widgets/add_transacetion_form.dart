import 'package:budgettraker/core/themes/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../utils/appvalidator.dart';
import 'category_dropdown.dart';

class AddTransactionForm extends StatefulWidget {
  const AddTransactionForm({super.key});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  var type = "credit";
  var category = "Others";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var isLoader = false;
  var appValidator = AppValidator();
  var amountEditController = TextEditingController();
  var titleEditController = TextEditingController();
  var uid = const Uuid();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        int timestamp = DateTime.now().millisecondsSinceEpoch;

        int amount = double.parse(amountEditController.text).toInt();
        DateTime date = DateTime.now();

        var id = uid.v4();
        String monthyear = DateFormat('MMM y').format(date);

        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get();
        int remainingAmount = (userDoc['remainingAmount'] as num).toInt();
        int totalCredit = (userDoc['totalCredit'] as num).toInt();
        int totalDebit = (userDoc['totalDebit'] as num).toInt();

        if (type == 'credit') {
          remainingAmount += amount;
          totalCredit += amount;
        } else {
          remainingAmount -= amount;
          totalDebit += amount;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              "remainingAmount": remainingAmount,
              "totalCredit": totalCredit,
              "totalDebit": totalDebit,
              "updatedAt": timestamp,
            });

        // Creating a new transaction record
        var data = {
          "id": id,
          "title": titleEditController.text,
          "amount": amount,
          "type": type,
          "timestamp": timestamp,
          "totalCredit": totalCredit,
          "totalDebit": totalDebit,
          "remainingAmount": remainingAmount,
          "monthyear": monthyear,
          "category": category,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection("transactions")
            .doc(id)
            .set(data);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        print("Error in form submission: $e");
      } finally {
        setState(() {
          isLoader = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: titleEditController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: appValidator.isEmptyCheck,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    color: AppColors.iconColor,
                    width: 4.0,
                  ),
                ),
              ),
              style: const TextStyle(color: AppColors.textColor),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: amountEditController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: appValidator.isEmptyCheck,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    color: AppColors.textColor,
                    width: 4.0,
                  ),
                ),
              ),
              style: const TextStyle(color: AppColors.textColor),
            ),
            const SizedBox(height: 10),
            CategoryDropDown(
              cattype: category,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: 'credit',
              items: const [
                DropdownMenuItem(value: 'credit', child: Text('Credit')),
                DropdownMenuItem(value: 'debit', child: Text('Debit')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isLoader == false) {
                  _submitForm();
                }
              },
              child:
                  isLoader
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.background,
                        ),
                      )
                      : const Text("Add Transaction"),
            ),
          ],
        ),
      ),
    );
  }
}
