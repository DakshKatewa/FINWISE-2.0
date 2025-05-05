import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen has AppBar and navigation items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
