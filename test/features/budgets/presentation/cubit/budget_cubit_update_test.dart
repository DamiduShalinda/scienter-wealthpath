import 'package:flutter_test/flutter_test.dart';
import 'package:wealthpath/features/budgets/domain/entities/budget_entity.dart';
import 'package:wealthpath/features/budgets/domain/entities/budget_page_entity.dart';
import 'package:wealthpath/features/budgets/domain/repositories/budget_repository.dart';
import 'package:wealthpath/features/budgets/domain/usecases/cache_budgets.dart';
import 'package:wealthpath/features/budgets/domain/usecases/get_budgets.dart';
import 'package:wealthpath/features/budgets/domain/usecases/get_cached_budgets.dart';
import 'package:wealthpath/features/budgets/domain/usecases/update_budget_limit.dart';
import 'package:wealthpath/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:wealthpath/features/budgets/presentation/cubit/budget_state.dart';

class _UpdateFakeBudgetRepository implements BudgetRepository {
  _UpdateFakeBudgetRepository({
    required this.initialBudgets,
    this.shouldFail = false,
  });

  final List<BudgetEntity> initialBudgets;
  final bool shouldFail;
  List<BudgetEntity> cached = <BudgetEntity>[];

  @override
  Future<void> cacheBudgets(List<BudgetEntity> budgets) async {
    cached = List<BudgetEntity>.from(budgets);
  }

  @override
  Future<List<BudgetEntity>> getCachedBudgets() async => const <BudgetEntity>[];

  @override
  Future<BudgetPageEntity<BudgetEntity>> getBudgets({int page = 1, int limit = 20}) async {
    return BudgetPageEntity<BudgetEntity>(items: initialBudgets, hasMore: false);
  }

  @override
  Future<BudgetEntity> updateBudgetLimit(
    String id,
    double newLimit, {
    bool forceFail = false,
  }) async {
    if (shouldFail || forceFail) {
      throw Exception('forced failure');
    }

    final old = initialBudgets.firstWhere((b) => b.id == id);
    return BudgetEntity(
      id: old.id,
      category: old.category,
      spent: old.spent,
      limit: newLimit,
      currency: old.currency,
    );
  }
}

void main() {
  BudgetCubit createCubit(_UpdateFakeBudgetRepository repository) {
    return BudgetCubit(
      getBudgets: GetBudgets(repository),
      getCachedBudgets: GetCachedBudgets(repository),
      cacheBudgets: CacheBudgets(repository),
      updateBudgetLimit: UpdateBudgetLimit(repository),
    );
  }

  test('optimistic budget update succeeds and keeps new limit', () async {
    final repository = _UpdateFakeBudgetRepository(
      initialBudgets: <BudgetEntity>[
        const BudgetEntity(id: 'bud_1', category: 'Groceries', spent: 40, limit: 100, currency: 'USD'),
      ],
    );
    final cubit = createCubit(repository);
    addTearDown(cubit.close);

    await cubit.loadBudgets();
    await cubit.updateBudgetLimitOptimistic('bud_1', 180);

    final state = cubit.state as BudgetLoaded;
    expect(state.budgets.first.limit, 180);
    expect(repository.cached.first.limit, 180);
  });

  test('optimistic budget update rolls back on failure', () async {
    final repository = _UpdateFakeBudgetRepository(
      initialBudgets: <BudgetEntity>[
        const BudgetEntity(id: 'bud_1', category: 'Groceries', spent: 40, limit: 100, currency: 'USD'),
      ],
      shouldFail: true,
    );
    final cubit = createCubit(repository);
    addTearDown(cubit.close);

    await cubit.loadBudgets();
    await cubit.updateBudgetLimitOptimistic('bud_1', 180);

    final state = cubit.state as BudgetLoaded;
    expect(state.budgets.first.limit, 100);
    expect(repository.cached.first.limit, 100);
  });
}
