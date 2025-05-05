import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/services/auth_service.dart';

class MockAuthService extends AuthService {
  @override
  Future<bool> signIn(String email, String password) async {
    return email == 'test@test.com' && password == 'password';
  }
}

void main() {
  final authService = MockAuthService();

  test('signs in with correct credentials', () async {
    final result = await authService.signIn('test@test.com', 'password');
    expect(result, true);
  });

  test('fails with incorrect credentials', () async {
    final result = await authService.signIn('wrong@test.com', '1234');
    expect(result, false);
  });
}
