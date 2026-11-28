import 'package:flutter/foundation.dart';

/// Configuración por ambiente: flutter run --dart-define=API_URL=https://api.zugar.mx/api/v1
/// Sin API_URL:
/// - En el teléfono o el emulador de Android: http://10.0.2.2:3000/api/v1 («localhost» de la computadora).
/// - En la versión web: el puerto 3000 del mismo servidor que sirve la app (localhost, la IP de la red o el puerto
///   reenviado de VS Code: https://abc-5600.usw2.devtunnels.ms → https://abc-3000.usw2.devtunnels.ms).
/// - Publicada con un túnel de Cloudflare (https://xxx.trycloudflare.com): /api/v1 del mismo dominio.
abstract final class Env {
  static const _fromDefine = String.fromEnvironment('API_URL');

  /// flutter run --dart-define=DEMO=true: pantallas con datos de ejemplo, sin API (network/demo_adapter.dart).
  static const demo = bool.fromEnvironment('DEMO');

  static String get apiUrl {
    if (demo) return 'http://demo.local/api/v1';
    if (_fromDefine.isNotEmpty) return _fromDefine;
    if (kIsWeb) return apiFor(Uri.base);
    return 'http://10.0.2.2:3000/api/v1';
  }

  /// URL de la API para la app web servida en [page].
  @visibleForTesting
  static String apiFor(Uri page) {
    final host = page.host;
    // Túnel público de Cloudflare: el mismo servidor de la app reenvía /api a la API (un solo dominio)
    if (host.toLowerCase().endsWith('.trycloudflare.com')) return '${page.scheme}://$host/api/v1';
    final tunnel = RegExp(r'^[a-z0-9]+-\d+\.', caseSensitive: false);
    if (tunnel.hasMatch(host) && host.toLowerCase().endsWith('.devtunnels.ms')) {
      return '${page.scheme}://${host.replaceFirst(RegExp(r'-\d+\.'), '-3000.')}/api/v1';
    }
    return '${page.scheme}://$host:3000/api/v1';
  }
}
