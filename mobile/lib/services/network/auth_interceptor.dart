import 'package:dio/dio.dart';

import 'token_storage.dart';

/// Agrega el token Bearer y, ante un 401, renueva la sesión UNA sola vez y repite la petición.
/// Es un QueuedInterceptor: si llegan varios 401 a la vez, solo se hace una renovación.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({required this.storage, required this.refreshDio, required this.onSessionExpired});

  final TokenStorage storage;

  /// Cliente sin interceptores para /auth/refresh y para repetir la petición. Repetir con el
  /// cliente principal bloquearía la cola si el reintento también respondiera 401.
  final Dio refreshDio;

  /// Se llama cuando la renovación falla: la app regresa al login.
  final void Function() onSessionExpired;

  static const retriedKey = 'homiz.retried';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.readAccess();
    if (token != null && !options.path.startsWith('/auth/login') && !options.path.startsWith('/auth/register')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isAuthCall = request.path.startsWith('/auth/');
    if (err.response?.statusCode != 401 || isAuthCall || request.extra[retriedKey] == true) {
      return handler.next(err);
    }

    final refresh = await storage.readRefresh();
    if (refresh == null) {
      onSessionExpired();
      return handler.next(err);
    }

    // Si otra petición ya renovó mientras esta esperaba en la cola, solo se repite con el token nuevo.
    final current = await storage.readAccess();
    final sent = (request.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');
    if (current != null && sent != null && current != sent) {
      return _retry(request, current, handler, err);
    }

    try {
      final res = await refreshDio.post<Map<String, dynamic>>('/auth/refresh', data: {'refreshToken': refresh});
      final access = res.data!['accessToken'] as String;
      await storage.save(access: access, refresh: res.data!['refreshToken'] as String);
      return await _retry(request, access, handler, err);
    } on DioException {
      await storage.clear();
      onSessionExpired();
      return handler.next(err);
    }
  }

  Future<void> _retry(RequestOptions request, String token, ErrorInterceptorHandler handler, DioException original) async {
    try {
      final response = await refreshDio.fetch<dynamic>(
        request
          ..headers['Authorization'] = 'Bearer $token'
          ..extra[retriedKey] = true,
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
