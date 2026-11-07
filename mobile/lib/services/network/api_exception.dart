import 'package:dio/dio.dart';

/// Error de la API con el formato { error: { code, message, details } }.
class ApiException implements Exception {
  const ApiException({required this.code, required this.message, this.status, this.details});

  final String code;
  final String message;
  final int? status;
  final Object? details;

  static const networkMessage = 'No pudimos conectar con Zugar. Revisa tu conexión e intenta de nuevo.';
  static const unknownMessage = 'Ocurrió un error inesperado. Intenta de nuevo.';

  bool get isNetwork => code == 'NETWORK';
  bool get isUnauthenticated => status == 401;

  /// Mensajes por campo cuando la API responde VALIDATION_ERROR: { campo: [mensajes] }.
  Map<String, String> get fieldErrors {
    final d = details;
    if (d is! Map) return const {};
    return {
      for (final e in d.entries)
        if (e.value is List && (e.value as List).isNotEmpty) '${e.key}': '${(e.value as List).first}',
    };
  }

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ApiException(code: 'NETWORK', message: networkMessage);
      default:
        break;
    }
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      final err = data['error'] as Map;
      return ApiException(
        code: '${err['code'] ?? 'UNKNOWN'}',
        message: '${err['message'] ?? unknownMessage}',
        status: e.response?.statusCode,
        details: err['details'],
      );
    }
    return ApiException(code: 'UNKNOWN', message: unknownMessage, status: e.response?.statusCode);
  }

  /// Convierte cualquier error en ApiException (para mostrar siempre un mensaje claro).
  static ApiException from(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      final inner = error.error;
      return inner is ApiException ? inner : ApiException.fromDio(error);
    }
    return const ApiException(code: 'UNKNOWN', message: unknownMessage);
  }

  @override
  String toString() => 'ApiException($code, $status): $message';
}
