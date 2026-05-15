import 'package:dio/dio.dart';

import '../../domain/entities/create_spending_input.dart';
import '../models/spending_model.dart';
import '../models/spending_page_model.dart';

abstract class SpendingRemoteDataSource {
  Future<SpendingPageModel> getSpending({int page = 1, int limit = 20});
  Future<SpendingModel> addSpending(CreateSpendingInput input);
}

class SpendingRemoteDataSourceImpl implements SpendingRemoteDataSource {
  SpendingRemoteDataSourceImpl({
    required Dio dio,
    this.baseUrl = 'https://wealthpath-assessment-api-production.up.railway.app/api/v1',
  }) : _dio = dio;

  final Dio _dio;
  final String baseUrl;

  @override
  Future<SpendingPageModel> getSpending({int page = 1, int limit = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/spending',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
      },
    );

    return SpendingPageModel.fromJson(response.data ?? <String, dynamic>{});
  }

  @override
  Future<SpendingModel> addSpending(CreateSpendingInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$baseUrl/spending',
      data: <String, dynamic>{
        'merchant': input.merchant,
        'amount': input.amount,
        'category': input.category,
        'currency': input.currency,
      },
    );

    return SpendingModel.fromJson(response.data ?? <String, dynamic>{});
  }
}
