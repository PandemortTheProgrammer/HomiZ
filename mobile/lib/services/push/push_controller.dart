import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notifications_provider.dart';
import '../network/api_client.dart';
import '../../screens/app_router.dart';
import '../utils/env.dart';
import 'firebase_options.dart';

/// true si Firebase se inició al arrancar (main.dart). En pruebas y en plataformas sin configuración: false.
final firebaseReadyProvider = Provider<bool>((ref) => false);

/// Para mostrar los avisos que llegan con la app abierta.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Inicia Firebase si la plataforma ya está registrada en el proyecto. Nunca falla: sin Firebase no hay push.
Future<bool> initFirebase() async {
  final options = Env.demo ? null : FirebaseConfig.currentPlatform;
  if (options == null) return false;
  try {
    await Firebase.initializeApp(options: options);
    return true;
  } catch (e) {
    debugPrint('Firebase no se pudo iniciar: $e');
    return false;
  }
}

/// Avisos push (Firebase Cloud Messaging) de la cuenta con sesión: HomizApp registra el dispositivo al entrar
/// y SessionController.logout lo da de baja (por eso este proveedor no escucha a la sesión).
final pushProvider = Provider<PushController>((ref) {
  final c = PushController(ref);
  ref.onDispose(c.dispose);
  return c;
});

class PushController {
  PushController(this._ref);

  final Ref _ref;
  final _subs = <StreamSubscription<Object?>>[];
  String? _token;
  bool _busy = false;

  bool get _enabled => _ref.read(firebaseReadyProvider);
  Dio get _dio => _ref.read(dioProvider);

  static String get _platform => kIsWeb ? 'web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');

  Future<void> register() async {
    if (!_enabled || _busy) return;
    _busy = true;
    try {
      final m = FirebaseMessaging.instance;
      final settings = await m.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      // El servidor envía por token de FCM (API HTTP v1, igual que el panel web). register()/onRegistered
      // entregan el ID de instalación para otro modo de envío, por eso se usa getToken.
      // ignore: deprecated_member_use
      final token = await m.getToken(vapidKey: kIsWeb ? FirebaseConfig.vapidKey : null);
      if (token == null) return;
      await _send(token);
      if (_subs.isEmpty) {
        _subs
          // ignore: deprecated_member_use
          ..add(m.onTokenRefresh.listen(_send))
          ..add(FirebaseMessaging.onMessage.listen(_onForeground))
          ..add(FirebaseMessaging.onMessageOpenedApp.listen(_open));
        final initial = await m.getInitialMessage(); // la app se abrió tocando un aviso
        if (initial != null) _open(initial);
      }
    } catch (e) {
      debugPrint('No se pudo activar el push: $e'); // se reintenta en el próximo inicio de sesión
    } finally {
      _busy = false;
    }
  }

  Future<void> _send(String token) async {
    _token = token;
    await _dio.post<void>('/devices', data: {'fcmToken': token, 'platform': _platform});
  }

  /// Antes de cerrar sesión: este dispositivo deja de recibir los avisos de la cuenta.
  Future<void> unregister() async {
    final token = _token;
    if (token == null) return;
    _token = null;
    try {
      await _dio.delete<void>('/devices/${Uri.encodeComponent(token)}');
    } on DioException {
      // Sin conexión: el servidor borra los tokens inválidos al enviar.
    }
  }

  void _onForeground(RemoteMessage msg) {
    _ref.invalidate(notificationsProvider);
    final n = msg.notification;
    if (n == null) return;
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text([n.title, n.body].whereType<String>().join(': ')),
      action: SnackBarAction(label: 'Ver', onPressed: () => _open(msg)),
    ));
  }

  /// Al tocar el aviso: la cita si es de una cita; si no, la bandeja de notificaciones.
  void _open(RemoteMessage msg) {
    final entity = msg.data['entity'], id = msg.data['entityId'];
    final router = _ref.read(routerProvider);
    router.go(entity == 'appointment' && id is String && id.isNotEmpty ? '/appointments/$id' : '/notifications');
  }

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
  }
}
