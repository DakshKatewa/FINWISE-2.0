import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/screens/splash.dart';

void main() {
  testWidgets('Splash screen shows logo and text', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('Welcome'), findsOneWidget);
  });
}
