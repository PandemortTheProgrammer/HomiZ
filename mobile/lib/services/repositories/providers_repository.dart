import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_call.dart';
import '../network/api_client.dart';
import '../../models/service_provider.dart';

final providersRepositoryProvider = Provider<ProvidersRepository>((ref) => ProvidersRepository(ref.watch(dioProvider)));

/// Directorio de proveedores (solo personal).
class ProvidersRepository {
  ProvidersRepository(this._dio);

  final Dio _dio;

  Future<List<ServiceProvider>> list({String? q}) => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/providers', queryParameters: {
          'limit': 100,
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        });
        return dataList(res.data, ServiceProvider.fromJson);
      });
}
