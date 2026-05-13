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

class _FakeBudgetRepository implements BudgetRepository {
  _FakeBudgetRepository({
    required this.pages,
  });

  final Map<int, BudgetPageEntity<BudgetEntity>> pages;
  final List<int> requestedPages = <int>[];

  @override
  Future<void> cacheBudgets(List<BudgetEntity> budgets) async {}

  @override
  Future<List<BudgetEntity>> getCachedBudgets() async => const <BudgetEntity>[];

  @override
  Future<BudgetPageEntity<BudgetEntity>> getBudgets({int page = 1, int limit = 20}) async {
    requestedPages.add(page);
    return pages[page] ?? const BudgetPageEntity<BudgetEntity>(items: <BudgetEntity>[], hasMore: false);
  }

  @override
  Future<BudgetEntity> updateBudgetLimit(
    String id,
    double newLimit, {
    bool forceFail = false,
  }) async {
    throw Exception('not implemented');
  }
}

void main() {
  BudgetCubit createCubit(_FakeBudgetRepository repository) {
    return BudgetCubit(
      getBudgets: GetBudgets(repository),
      getCachedBudgets: GetCachedBudgets(repository),
      cacheBudgets: CacheBudgets(repository),
      updateBudgetLimit: UpdateBudgetLimit(repository),
    );
  }

  test('search filters categories client-side after 300ms debounce', () async {
    final budgets = <BudgetEntity>[
      const BudgetEntity(id: '1', category: 'Groceries', spent: 10, limit: 100, currency: 'USD'),
      const BudgetEntity(id: '2', category: 'Dining', spent: 20, limit: 100, currency: 'USD'),
      const BudgetEntity(id: '3', category: 'Transport', spent: 30, limit: 100, currency: 'USD'),
    ];
    final repository = _FakeBudgetRepository(
      pages: <int, BudgetPageEntity<BudgetEntity>>{
        1: BudgetPageEntity<BudgetEntity>(items: budgets, hasMore: false),
      },
    );

    final cubit = createCubit(repository);
    addTearDown(cubit.close);

    await cubit.loadBudgets();
    expect(cubit.state, isA<BudgetLoaded>());

    cubit.onSearchChanged('din');

    final immediate = cubit.state as BudgetLoaded;
    expect(immediate.filteredBudgets.length, 3);

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final updated = cubit.state as BudgetLoaded;
    expect(updated.searchQuery, 'din');
    expect(updated.filteredBudgets.length, 1);
    expect(updated.filteredBudgets.first.category, 'Dining');
  });

  test('search debounce keeps only latest query', () async {
    final budgets = <BudgetEntity>[
      const BudgetEntity(id: '1', category: 'Groceries', spent: 10, limit: 100, currency: 'USD'),
      const BudgetEntity(id: '2', category: 'Gaming', spent: 20, limit: 100, currency: 'USD'),
    ];
    final repository = _FakeBudgetRepository(
      pages: <int, BudgetPageEntity<BudgetEntity>>{
        1: BudgetPageEntity<BudgetEntity>(items: budgets, hasMore: false),
      },
    );

    final cubit = createCubit(repository);
    addTearDown(cubit.close);

    await cubit.loadBudgets();
    cubit.onSearchChanged('gro');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    cubit.onSearchChanged('gam');

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final state = cubit.state as BudgetLoaded;
    expect(state.searchQuery, 'gam');
    expect(state.filteredBudgets.length, 1);
    expect(state.filteredBudgets.first.category, 'Gaming');
  });

  test('pagination appends next page and respects hasMore', () async {
    final page1 = <BudgetEntity>[
      const BudgetEntity(id: '1', category: 'Groceries', spent: 10, limit: 100, currency: 'USD'),
    ];
    final page2 = <BudgetEntity>[
      const BudgetEntity(id: '2', category: 'Dining', spent: 20, limit: 100, currency: 'USD'),
    ];
    final repository = _FakeBudgetRepository(
      pages: <int, BudgetPageEntity<BudgetEntity>>{
        1: BudgetPageEntity<BudgetEntity>(items: page1, hasMore: true),
        2: BudgetPageEntity<BudgetEntity>(items: page2, hasMore: false),
      },
    );

    final cubit = createCubit(repository);
    addTearDown(cubit.close);

    await cubit.loadBudgets();
    await cubit.loadMoreBudgets();
    await cubit.loadMoreBudgets();

    final state = cubit.state as BudgetLoaded;
    expect(state.budgets.length, 2);
    expect(state.hasMore, false);
    expect(repository.requestedPages, <int>[1, 2]);
  });
}
