import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
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
}
