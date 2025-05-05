import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/screens/reports_screen.dart';

void main() {
  testWidgets('Reports screen shows report items or list views', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ReportsScreen()));
    expect(find.textContaining('Report'), findsWidgets);
    expect(find.byType(ListView), findsWidgets);
  });
}
