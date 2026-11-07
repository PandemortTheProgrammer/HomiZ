import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Ejecuta una llamada a la API y convierte los errores de Dio en [ApiException].
Future<T> apiCall<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } on DioException catch (e) {
    throw ApiException.from(e);
  }
}

/// Lista de una respuesta paginada `{ data: [...] }`.
List<T> dataList<T>(Map<String, dynamic>? body, T Function(Map<String, dynamic>) fromJson) =>
    [for (final item in (body?['data'] as List? ?? const [])) fromJson(item as Map<String, dynamic>)];
