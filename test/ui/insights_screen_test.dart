import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/screens/insights_screen.dart';

void main() {
  testWidgets('Insights screen shows charts or insights text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: InsightsScreen()));
    expect(find.textContaining('Insights'), findsWidgets);
    expect(find.byType(Container), findsWidgets);
  });
}
