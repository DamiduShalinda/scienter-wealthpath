import 'package:flutter_test/flutter_test.dart';
import 'package:wealthpath/features/budgets/domain/entities/budget_entity.dart';

void main() {
  group('BudgetEntity spend calculations', () {
    test('returns normalized ratio and percentage for valid limit', () {
      const budget = BudgetEntity(
        id: 'bud_001',
        category: 'Groceries',
        spent: 120,
        limit: 300,
        currency: 'USD',
      );

      expect(budget.spendRatio, closeTo(0.4, 0.0001));
      expect(budget.spendPercentage, closeTo(40, 0.0001));
    });

    test('returns zero when limit is zero or negative', () {
      const zeroLimit = BudgetEntity(
        id: 'bud_002',
        category: 'Dining',
        spent: 80,
        limit: 0,
        currency: 'USD',
      );

      const negativeLimit = BudgetEntity(
        id: 'bud_003',
        category: 'Transport',
        spent: 80,
        limit: -10,
        currency: 'USD',
      );

      expect(zeroLimit.spendRatio, 0);
      expect(zeroLimit.spendPercentage, 0);
      expect(negativeLimit.spendRatio, 0);
      expect(negativeLimit.spendPercentage, 0);
    });

    test('clamps ratio and percentage to avoid values above 100%', () {
      const budget = BudgetEntity(
        id: 'bud_004',
        category: 'Shopping',
        spent: 500,
        limit: 300,
        currency: 'USD',
      );

      expect(budget.spendRatio, 1);
      expect(budget.spendPercentage, 100);
    });
  });
}
