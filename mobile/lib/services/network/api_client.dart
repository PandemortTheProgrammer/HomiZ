import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/env.dart';
import 'auth_interceptor.dart';
import 'demo_adapter.dart';
import 'token_storage.dart';

/// Almacenamiento de tokens (se reemplaza por MemoryTokenStorage en pruebas).
final tokenStorageProvider = Provider<TokenStorage>((ref) => FallbackTokenStorage(SecureTokenStorage()));

/// URL base de la API (se puede reemplazar en pruebas).
final apiBaseUrlProvider = Provider<String>((ref) => Env.apiUrl);

/// Adaptador HTTP; null usa el de Dio. En modo demo contesta DemoAdapter, sin API.
final httpAdapterProvider = Provider<HttpClientAdapter?>((ref) => Env.demo ? DemoAdapter() : null);

/// Aviso de sesión expirada: el interceptor lo dispara y la sesión lo escucha.
final sessionExpiredProvider = NotifierProvider<SessionExpiredNotifier, int>(SessionExpiredNotifier.new);

class SessionExpiredNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void fire() => state++;
}

Dio _client(String baseUrl, HttpClientAdapter? adapter) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json'},
  ));
  if (adapter != null) dio.httpClientAdapter = adapter;
  return dio;
}

/// Cliente HTTP con el interceptor de sesión.
final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final adapter = ref.watch(httpAdapterProvider);
  final dio = _client(baseUrl, adapter);
  dio.interceptors.add(
    AuthInterceptor(
      storage: ref.watch(tokenStorageProvider),
      refreshDio: _client(baseUrl, adapter),
      onSessionExpired: () => ref.read(sessionExpiredProvider.notifier).fire(),
    ),
  );
  return dio;
});
