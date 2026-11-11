import 'package:dio/dio.dart';
import '../utils/formatters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_call.dart';
import '../network/api_client.dart';
import '../../models/request_models.dart';

export '../../models/request_models.dart';

final requestsRepositoryProvider = Provider<RequestsRepository>((ref) => RequestsRepository(ref.watch(dioProvider)));

class RequestsRepository {
  RequestsRepository(this._dio);

  final Dio _dio;

  /// Mensajes: el personal usa /leads; el cliente, /requests.
  Future<List<RequestMessage>> messages(String id, {required bool staff}) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('${staff ? '/leads' : '/requests'}/$id/messages');
    return dataList(res.data, RequestMessage.fromJson);
  });

  Future<List<RequestMessage>> send(String id, String body, {required bool staff}) => apiCall(() async {
    final res = await _dio.post<Map<String, dynamic>>('${staff ? '/leads' : '/requests'}/$id/messages', data: {'body': body.trim()});
    return dataList(res.data, RequestMessage.fromJson);
  });

  /* ---------- Cliente: «Mis solicitudes» ---------- */

  Future<List<LeadRequest>> mine() => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/requests');
    return dataList(res.data, LeadRequest.fromJson);
  });

  Future<LeadRequest> mineOne(String id) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/requests/$id');
    return LeadRequest.fromJson(res.data!);
  });

  /// «¿Qué quieres hacer?»: el nombre, correo y teléfono salen de la cuenta. Los montos van como número.
  /// Con [propertySlug], [preferredDate] (AAAA-MM-DD) y [preferredTime] (HH:MM) se agenda además la cita.
  Future<LeadRequest> create({
    required String reason,
    String? message,
    required Map<String, Object?> payload,
    String? propertySlug,
    String? propertyCode,
    String? preferredDate,
    String? preferredTime,
  }) => apiCall(() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/requests',
      data: {
        'reason': reason,
        'propertySlug': ?propertySlug,
        'propertyCode': ?propertyCode,
        'preferredDate': ?preferredDate,
        'preferredTime': ?preferredTime,
        if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
        'payload': {
          for (final e in payload.entries)
            if (e.value is num) e.key: e.value else if (e.value is String && (e.value! as String).trim().isNotEmpty) e.key: (e.value! as String).trim(),
        },
      },
    );
    return LeadRequest.fromJson(res.data!);
  });

  /// El cliente corrige lo que mandó; lo que deje vacío se borra.
  Future<void> edit(String id, {String? message, required Map<String, Object?> payload}) => apiCall(() async {
    await _dio.patch<Map<String, dynamic>>(
      '/requests/$id',
      data: {
        'message': (message ?? '').trim().isEmpty ? null : message!.trim(),
        'payload': {
          for (final e in payload.entries)
            if (e.value is num) e.key: e.value else if (e.value is String && (e.value! as String).trim().isNotEmpty) e.key: (e.value! as String).trim(),
        },
      },
    );
  });

  /* ---------- Personal (leads.manage): contestar y proponer casas ---------- */

  /// [status] "sin_asignar" = las que aún no tienen broker.
  Future<List<LeadRequest>> staffList({String? status}) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/leads', queryParameters: {'limit': 100, if (status == 'sin_asignar') 'unassigned': 'true' else 'status': ?status});
    return dataList(res.data, LeadRequest.fromJson);
  });

  Future<LeadRequest> staffOne(String id) => apiCall(() async {
    final res = await _dio.get<Map<String, dynamic>>('/leads/$id');
    return LeadRequest.fromJson(res.data!);
  });

  Future<void> update(String id, {String? status, String? response}) => apiCall(() async {
    await _dio.patch<Map<String, dynamic>>('/leads/$id', data: {'status': ?status, 'response': ?response});
  });

  Future<void> propose(String id, String propertyId, {String? note}) => apiCall(() async {
    await _dio.post<Map<String, dynamic>>('/leads/$id/proposals', data: {'propertyId': propertyId, if (note != null && note.trim().isNotEmpty) 'note': note.trim()});
  });

  Future<void> unpropose(String id, String proposalId) => apiCall(() async {
    await _dio.delete<Map<String, dynamic>>('/leads/$id/proposals/$proposalId');
  });

  /// Agenda la visita desde la solicitud; devuelve la clave de la cita (CIT-…).
  /// Con [agreed], el personal acepta la fecha y hora que pidió la persona y la cita queda confirmada.
  Future<String> schedule(String id, {required String propertyId, required DateTime at, String? note, bool agreed = false}) => apiCall(() async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/leads/$id/appointment',
      data: {'propertyId': propertyId, 'scheduledAt': cancunIso(at), if (note != null && note.trim().isNotEmpty) 'note': note.trim(), if (agreed) 'agreed': true},
    );
    return (res.data!['appointment'] as Map<String, dynamic>)['code'] as String;
  });

  /// El broker toma una solicitud sin broker: se queda con su seguimiento.
  Future<void> take(String id) => apiCall(() async {
    await _dio.post<Map<String, dynamic>>('/leads/$id/take');
  });

  /// Solo administración: asigna el broker; la cita (si hay) se va con él y los datos de la persona no cambian.
  Future<void> assign(String id, String brokerId) => apiCall(() async {
    await _dio.patch<Map<String, dynamic>>('/leads/$id/broker', data: {'brokerId': brokerId});
  });

  /// Brokers activos (administración). Si no puede ver al personal, salen de las casas.
  Future<List<({String id, String name})>> brokers() => apiCall(() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/users', queryParameters: {'limit': 100});
      return [
        for (final u in (res.data?['data'] as List? ?? const []).cast<Map<String, dynamic>>())
          if ((u['roles'] as List? ?? const []).contains('broker') && u['active'] != false) (id: u['id'] as String, name: u['name'] as String),
      ];
    } on DioException {
      final res = await _dio.get<Map<String, dynamic>>('/properties', queryParameters: {'limit': 100});
      final seen = <String, String>{};
      for (final p in (res.data?['data'] as List? ?? const []).cast<Map<String, dynamic>>()) {
        final b = p['broker'] as Map<String, dynamic>?;
        if (b != null) seen[b['id'] as String] = b['name'] as String;
      }
      return [for (final e in seen.entries) (id: e.key, name: e.value)];
    }
  });

  /// Solo administración.
  Future<void> remove(String id) => apiCall(() async {
    await _dio.delete<void>('/leads/$id');
  });
}

/// Fecha y hora elegidas como hora de Cancún (UTC-5, sin horario de verano): 2026-11-03T10:00:00-05:00
String cancunIso(DateTime at) => Fmt.cancunIso(at);
