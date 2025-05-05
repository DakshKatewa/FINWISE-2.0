import 'package:flutter_test/flutter_test.dart';
import 'package:budgettraker/utils/icons_list.dart';
import 'package:flutter/material.dart';

void main() {
  var iconsList = AppIcons();
  test('Icons list is not empty', () {
    expect(iconsList.homeExpensesCategories.isNotEmpty, true);
  });

  test('Icons list contains only IconData', () {
    for (var icon in iconsList.homeExpensesCategories) {
      expect(icon, isA<IconData>());
    }
  });
}
