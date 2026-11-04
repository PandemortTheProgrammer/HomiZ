import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../models/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider), ref.watch(tokenStorageProvider)),
);

/// Llamadas de autenticación y perfil propio.
class AuthRepository {
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  Future<T> _call<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<AppUser> _startSession(Map<String, dynamic> data) async {
    await _storage.save(access: data['accessToken'] as String, refresh: data['refreshToken'] as String);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<bool> hasStoredSession() async => (await _storage.readAccess()) != null;

  Future<AppUser> login({required String email, required String password}) => _call(() async {
        final res = await _dio.post<Map<String, dynamic>>('/auth/login', data: {'email': email.trim(), 'password': password});
        return _startSession(res.data!);
      });

  /// Crea una cuenta de cliente.
  Future<AppUser> register({required String name, required String email, required String phone, required String password}) => _call(() async {
        final res = await _dio.post<Map<String, dynamic>>('/auth/register', data: {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
          // Solo se llama después de marcar «Acepto el aviso de privacidad»
          'consent': true,
        });
        return _startSession(res.data!);
      });

  Future<AppUser> me() => _call(() async {
        final res = await _dio.get<Map<String, dynamic>>('/users/me');
        return AppUser.fromJson(res.data!);
      });

  /// [client]: datos del expediente del cliente (`budgetAmount`, `hasPets`, `petsCount`, `occupants`).
  Future<AppUser> updateProfile({String? name, String? phone, String? birthDate, Map<String, Object?>? client}) => _call(() async {
        final res = await _dio.patch<Map<String, dynamic>>('/users/me', data: {
          if (name != null) 'name': name.trim(),
          if (phone != null) 'phone': phone.trim(),
          'birthDate': ?birthDate,
          'client': ?client,
        });
        return AppUser.fromJson(res.data!);
      });

  /// Cambia la contraseña. La API cierra las demás sesiones y entrega tokens nuevos para esta.
  Future<String> changePassword({required String current, required String next}) => _call(() async {
        final res = await _dio.post<Map<String, dynamic>>('/auth/change-password', data: {'currentPassword': current, 'newPassword': next});
        final data = res.data ?? const {};
        if (data['accessToken'] is String && data['refreshToken'] is String) {
          await _storage.save(access: data['accessToken'] as String, refresh: data['refreshToken'] as String);
        }
        return data['message'] as String? ?? 'Tu contraseña se actualizó.';
      });

  Future<String> forgotPassword(String email) => _call(() async {
        final res = await _dio.post<Map<String, dynamic>>('/auth/forgot-password', data: {'email': email.trim()});
        return res.data?['message'] as String? ?? '';
      });

  /// Crea la contraseña con el código del correo (cuenta nueva o recuperación).
  Future<void> resetPassword(String token, String password) => _call(() async {
        await _dio.post<Map<String, dynamic>>('/auth/reset-password', data: {'token': token, 'password': password});
      });

  /// «Eliminar mi cuenta» (derecho de cancelación): pide su contraseña. Después se borra la sesión local.
  Future<void> deleteAccount(String password) => _call(() async {
        await _dio.delete<void>('/users/me', data: {'password': password});
        await _storage.clear();
      });

  /// Cierra la sesión en la API (si no hay red, igual se borra la sesión local).
  Future<void> logout() async {
    final refresh = await _storage.readRefresh();
    try {
      if (refresh != null) await _dio.post<void>('/auth/logout', data: {'refreshToken': refresh});
    } on DioException {
      // Sin conexión o token ya inválido: la sesión local se borra de todas formas.
    } finally {
      await _storage.clear();
    }
  }
}
