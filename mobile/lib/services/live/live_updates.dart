import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../providers/appointments_provider.dart';
import '../providers/session_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/property_provider.dart';
import '../providers/requests_provider.dart';
import '../network/api_client.dart';
import '../utils/env.dart';

/// Respaldo cuando el WebSocket no conecta: cada cuánto se pregunta si hubo cambios (solo un número).
const livePollInterval = Duration(seconds: 6);

/// En las pruebas se apaga el WebSocket (no hay servidor) y queda la consulta periódica.
final liveSocketEnabledProvider = Provider<bool>((ref) => !Env.demo);

/// http(s)://host/api/v1 → ws(s)://host/api/v1/ws?token=… (si la API es relativa, con el dominio de la app web)
Uri liveSocketUri(String apiBase, String token) {
  final api = Uri.base.resolve(apiBase);
  final path = api.path.endsWith('/') ? api.path.substring(0, api.path.length - 1) : api.path;
  return api.replace(scheme: api.scheme == 'https' ? 'wss' : 'ws', path: '$path/ws', queryParameters: {'token': token});
}

/// Tiempo real: la API avisa por WebSocket cada cambio (citas, solicitudes, mensajes, avisos)
/// hecho en la app, el panel o el sitio; la app vuelve a cargar lo que se ve en pantalla al instante.
/// Si el WebSocket no conecta (red que lo bloquea), pregunta el contador cada [livePollInterval].
final liveUpdatesProvider = Provider<void>((ref) {
  final signedIn = ref.watch(sessionProvider.select((s) => s.value != null));
  if (!signedIn) return;
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(tokenStorageProvider);
  final useSocket = ref.watch(liveSocketEnabledProvider);
  int? last;
  var disposed = false;
  var attempts = 0;
  WebSocketChannel? channel;
  StreamSubscription<dynamic>? sub;
  Timer? retry;
  Timer? debounce;

  void seen(int seq) {
    if (last != null && seq != last) {
      // Varios cambios seguidos se juntan en una sola recarga
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 250), () => _refresh(ref));
    }
    last = seq;
  }

  Future<void> ask() async {
    try {
      final res = await dio.get<Map<String, dynamic>>('/events/seq');
      final seq = (res.data?['seq'] as num?)?.toInt();
      if (seq != null) seen(seq);
    } catch (_) {
      // Sin red o sesión vencida: se intenta en la siguiente vuelta
    }
  }

  // connect y reconnect se llaman entre sí
  late final void Function() reconnect;

  Future<void> connect() async {
    if (disposed || !useSocket) return;
    await ask(); // también renueva el token si venció (dura 15 minutos)
    final token = await storage.readAccess();
    if (disposed || token == null) return;
    try {
      final ch = channel = WebSocketChannel.connect(liveSocketUri(dio.options.baseUrl, token));
      await ch.ready;
      attempts = 0;
      sub = ch.stream.listen(
        (m) {
          try {
            final seq = ((jsonDecode(m as String) as Map)['seq'] as num?)?.toInt();
            if (seq != null) seen(seq);
          } catch (_) {}
        },
        onDone: () => reconnect(),
        onError: (_) => reconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      reconnect();
    }
  }

  reconnect = () {
    channel = null;
    sub?.cancel();
    if (disposed) return;
    attempts++;
    retry?.cancel();
    retry = Timer(Duration(seconds: min(30, 1 << min(attempts, 5))), connect);
  };

  connect();
  final poll = Timer.periodic(livePollInterval, (_) {
    if (channel == null) ask();
  });
  ref.onDispose(() {
    disposed = true;
    poll.cancel();
    retry?.cancel();
    debounce?.cancel();
    sub?.cancel();
    channel?.sink.close();
  });
});

void _refresh(Ref ref) {
  ref
    ..invalidate(notificationsProvider)
    ..invalidate(appointmentsProvider)
    ..invalidate(appointmentProvider)
    ..invalidate(appointmentMessagesProvider)
    ..invalidate(activeAppointmentProvider)
    ..invalidate(requestsProvider)
    ..invalidate(requestProvider)
    ..invalidate(requestMessagesProvider)
    ..invalidate(staffDashboardProvider)
    ..invalidate(clientDashboardProvider)
    ..invalidate(dossierProvider)
    ..invalidate(propertyDetailProvider);

}
