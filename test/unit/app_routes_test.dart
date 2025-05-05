import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/routes/app_routes.dart';

void main() {
  test('App routes contains initial and login routes', () {
    expect(AppRoutes.getRoutes().containsKey('/'), true);
    expect(AppRoutes.getRoutes().containsKey('/login'), true);
  });
}
