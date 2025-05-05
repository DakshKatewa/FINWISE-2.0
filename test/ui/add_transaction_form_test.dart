import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/widgets/add_transacetion_form.dart';

void main() {
  testWidgets('AddTransactionForm has required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AddTransactionForm())),
    );
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.text('Add'), findsOneWidget);
  });
}
