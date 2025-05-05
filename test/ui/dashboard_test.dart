import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/screens/dashboard.dart';

void main() {
  testWidgets('Dashboard screen shows summary cards or charts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Dashboard()));
    expect(find.textContaining('Dashboard'), findsWidgets);
    expect(find.byType(Card), findsWidgets);
  });
}
