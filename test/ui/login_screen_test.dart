import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/screens/login_screen.dart';

void main() {
  testWidgets('Login screen contains email and password fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login button triggers action', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));
    final loginButton = find.text('Login');
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pump();
  });
}
