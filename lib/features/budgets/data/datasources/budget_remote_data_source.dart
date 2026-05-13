import 'package:dio/dio.dart';

import '../models/budget_model.dart';
import '../models/budget_page_model.dart';

abstract class BudgetRemoteDataSource {
  Future<BudgetPageModel> getBudgets({int page = 1, int limit = 20});
  Future<BudgetModel> updateBudgetLimit(String id, double newLimit);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  BudgetRemoteDataSourceImpl({
    required Dio dio,
    this.baseUrl = 'https://wealthpath-assessment-api-production.up.railway.app/api/v1',
  }) : _dio = dio;

  final Dio _dio;
  final String baseUrl;

  @override
  Future<BudgetPageModel> getBudgets({int page = 1, int limit = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/budgets',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return BudgetPageModel.fromJson(response.data ?? <String, dynamic>{});
  }

  @override
  Future<BudgetModel> updateBudgetLimit(String id, double newLimit) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '$baseUrl/budgets/$id',
      data: <String, dynamic>{'limit': newLimit},
    );

    return BudgetModel.fromJson(response.data ?? <String, dynamic>{});
  }
}
