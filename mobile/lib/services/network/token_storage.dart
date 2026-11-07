import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda los tokens de sesión. En el teléfono usa almacenamiento cifrado (Keychain / Keystore).
abstract class TokenStorage {
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> save({required String access, required String refresh});
  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'homiz.access';
  static const _refreshKey = 'homiz.refresh';

  @override
  Future<String?> readAccess() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  @override
  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

/// Usa [primary] y, si falla, sigue en memoria. En la versión web servida por IP (sin HTTPS) el navegador
/// no ofrece WebCrypto y el almacenamiento cifrado no funciona; así la sesión dura mientras la pestaña esté abierta.
class FallbackTokenStorage implements TokenStorage {
  FallbackTokenStorage(this._primary);

  final TokenStorage _primary;
  final _memory = MemoryTokenStorage();
  bool _useMemory = false;

  Future<T> _run<T>(Future<T> Function(TokenStorage s) fn) async {
    if (_useMemory) return fn(_memory);
    try {
      return await fn(_primary);
    } catch (_) {
      _useMemory = true;
      return fn(_memory);
    }
  }

  @override
  Future<String?> readAccess() => _run((s) => s.readAccess());

  @override
  Future<String?> readRefresh() => _run((s) => s.readRefresh());

  @override
  Future<void> save({required String access, required String refresh}) => _run((s) => s.save(access: access, refresh: refresh));

  @override
  Future<void> clear() => _run((s) => s.clear());
}

/// Implementación en memoria (pruebas).
class MemoryTokenStorage implements TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async => access = refresh = null;
}
