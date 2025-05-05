import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/utils/appValidator.dart';

void main() {
  var appValidator = AppValidator();
  group('appValidator', () {
    test('validates correct email', () {
      expect(appValidator.validateEmail('test@example.com'), null);
    });

    test('rejects invalid email', () {
      expect(appValidator.validateEmail('test'), isNotNull);
    });

    test('validates non-empty password', () {
      expect(appValidator.validatePassword('password123'), null);
    });

    test('rejects empty password', () {
      expect(appValidator.validatePassword(''), isNotNull);
    });
  });
}
