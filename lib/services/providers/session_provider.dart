import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../models/app_user.dart';
import '../repositories/auth_repository.dart';

/// Sesión actual: null = sin sesión. Al arrancar intenta recuperar la sesión guardada.
final sessionProvider = AsyncNotifierProvider<SessionController, AppUser?>(SessionController.new);

/// Duración mínima de la pantalla de bienvenida.
final splashDelayProvider = FutureProvider<void>((ref) => Future<void>.delayed(const Duration(milliseconds: 1400)));

class SessionController extends AsyncNotifier<AppUser?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<AppUser?> build() async {
    // Si la renovación del token falla, la sesión termina y el router regresa al login.
    ref.listen(sessionExpiredProvider, (_, _) => state = const AsyncData(null));
    if (!await _repo.hasStoredSession()) return null;
    try {
      return await _repo.me();
    } on ApiException catch (e) {
      if (e.isNetwork) rethrow; // la bienvenida muestra «Reintentar»
      await ref.read(tokenStorageProvider).clear();
      return null;
    }
  }

  /// Contraseña temporal con la que acaba de entrar (solo en memoria), para no pedirla otra vez
  /// en «Crea tu contraseña».
  String? temporaryPassword;

  /// Acaba de crear su cuenta: el router abre «¿Qué quieres hacer?» una sola vez (NewRequestPage lo apaga).
  bool justRegistered = false;

  /// Los errores se propagan a la pantalla (mensaje de la API).
  Future<void> login(String email, String password) async {
    final user = await _repo.login(email: email, password: password);
    temporaryPassword = user.mustChangePassword ? password : null;
    state = AsyncData(user);
  }

  /// Tras entrar con la contraseña temporal: crea la suya y sigue dentro (la API entrega tokens nuevos).
  Future<void> createOwnPassword({required String current, required String next}) async {
    await _repo.changePassword(current: current, next: next);
    temporaryPassword = null;
    state = AsyncData(await _repo.me());
  }

  Future<void> register({required String name, required String email, required String phone, required String password}) async {
    final user = await _repo.register(name: name, email: email, phone: phone, password: password);
    justRegistered = true;
    state = AsyncData(user);
  }

  Future<void> refreshUser() async {
    state = AsyncData(await _repo.me());
  }

  void updateUser(AppUser user) => state = AsyncData(user);

  Future<void> logout() async {
    await ref.read(pushProvider).unregister(); // antes de borrar la sesión (necesita el token de acceso)
    await _repo.logout();
    await _forgetDeviceData();
    state = const AsyncData(null);
  }

  /// «Eliminar mi cuenta»: la API anonimiza los datos; en el teléfono se borran la sesión, fotos y documentos guardados.
  Future<void> deleteAccount(String password) async {
    await ref.read(pushProvider).unregister();
    await _repo.deleteAccount(password);
    await _forgetDeviceData();
    state = const AsyncData(null);
  }

  /// Si el teléfono se presta o se pierde, no quedan fotos ni documentos de la cuenta en caché.
  Future<void> _forgetDeviceData() async {
    PaintingBinding.instance.imageCache.clear();
    // En segundo plano: cerrar sesión no espera a que se vacíe el disco
    unawaited(() async {
      try {
        await DefaultCacheManager().emptyCache();
      } catch (_) {
        // Sin caché en disco (p. ej. en la versión web o en pruebas): no hay nada que borrar
      }
    }());
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
