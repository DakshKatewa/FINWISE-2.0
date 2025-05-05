import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/services/firestore_services_budget.dart';

class MockFirestoreService extends FirestoreService {
  @override
  Future<void> addBudget(String userId, double amount) async {
    if (amount < 0) throw Exception('Invalid amount');
  }
}

void main() {
  final service = MockFirestoreService();

  test('adds a valid budget', () async {
    await service.addBudget('user123', 100.0);
  });

  test('throws on negative budget', () async {
    expect(() => service.addBudget('user123', -50.0), throwsException);
  });
}
