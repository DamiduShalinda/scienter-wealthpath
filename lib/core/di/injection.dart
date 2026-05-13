import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wealthpath/core/database/app_database.dart';
import 'package:wealthpath/features/budgets/data/datasources/budget_local_data_source.dart';
import 'package:wealthpath/features/budgets/data/datasources/budget_remote_data_source.dart';
import 'package:wealthpath/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:wealthpath/features/budgets/domain/repositories/budget_repository.dart';
import 'package:wealthpath/features/budgets/domain/usecases/cache_budgets.dart';
import 'package:wealthpath/features/budgets/domain/usecases/get_budgets.dart';
import 'package:wealthpath/features/budgets/domain/usecases/get_cached_budgets.dart';
import 'package:wealthpath/features/budgets/domain/usecases/update_budget_limit.dart';
import 'package:wealthpath/features/spending/data/datasources/spending_remote_data_source.dart';
import 'package:wealthpath/features/spending/data/repositories/spending_repository_impl.dart';
import 'package:wealthpath/features/spending/domain/repositories/spending_repository.dart';
import 'package:wealthpath/features/spending/domain/usecases/add_spending.dart';
import 'package:wealthpath/features/spending/domain/usecases/get_spending.dart';
import 'package:wealthpath/features/spending/presentation/cubit/spending_cubit.dart';

final GetIt sl = GetIt.instance;

void configureDependencies() {
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => Dio());
  }

  if (!sl.isRegistered<AppDatabase>()) {
    sl.registerLazySingleton<AppDatabase>(AppDatabase.new);
  }

  if (!sl.isRegistered<SpendingRemoteDataSource>()) {
    sl.registerLazySingleton<SpendingRemoteDataSource>(
      () => SpendingRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }

  if (!sl.isRegistered<SpendingRepository>()) {
    sl.registerLazySingleton<SpendingRepository>(
      () => SpendingRepositoryImpl(sl<SpendingRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<SpendingCubit>()) {
    sl.registerFactory<SpendingCubit>(
      () => SpendingCubit(
        sl<GetSpending>(),
        sl<AddSpending>(),
      ),
    );
  }

  if (!sl.isRegistered<GetSpending>()) {
    sl.registerLazySingleton<GetSpending>(
      () => GetSpending(sl<SpendingRepository>()),
    );
  }

  if (!sl.isRegistered<AddSpending>()) {
    sl.registerLazySingleton<AddSpending>(
      () => AddSpending(sl<SpendingRepository>()),
    );
  }

  if (!sl.isRegistered<BudgetRemoteDataSource>()) {
    sl.registerLazySingleton<BudgetRemoteDataSource>(
      () => BudgetRemoteDataSourceImpl(dio: sl<Dio>()),
    );
  }

  if (!sl.isRegistered<BudgetLocalDataSource>()) {
    sl.registerLazySingleton<BudgetLocalDataSource>(
      () => BudgetLocalDataSourceImpl(sl<AppDatabase>()),
    );
  }

  if (!sl.isRegistered<BudgetRepository>()) {
    sl.registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(
        remoteDataSource: sl<BudgetRemoteDataSource>(),
        localDataSource: sl<BudgetLocalDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<GetBudgets>()) {
    sl.registerLazySingleton<GetBudgets>(
      () => GetBudgets(sl<BudgetRepository>()),
    );
  }

  if (!sl.isRegistered<UpdateBudgetLimit>()) {
    sl.registerLazySingleton<UpdateBudgetLimit>(
      () => UpdateBudgetLimit(sl<BudgetRepository>()),
    );
  }

  if (!sl.isRegistered<GetCachedBudgets>()) {
    sl.registerLazySingleton<GetCachedBudgets>(
      () => GetCachedBudgets(sl<BudgetRepository>()),
    );
  }

  if (!sl.isRegistered<CacheBudgets>()) {
    sl.registerLazySingleton<CacheBudgets>(
      () => CacheBudgets(sl<BudgetRepository>()),
    );
  }
}
