import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appointments_provider.dart';
import 'session_provider.dart';
import 'dashboard_provider.dart';
import '../repositories/requests_repository.dart';

bool _isStaff(Ref ref) => ref.watch(sessionProvider.select((s) => s.value?.isStaff ?? false));

/// Cliente: sus solicitudes. Personal: las del sitio y la app filtradas por [status] (null = todas).
final requestsProvider = FutureProvider.family<List<LeadRequest>, String?>((ref, status) {
  ref.watch(sessionProvider.select((s) => s.value?.id));
  final repo = ref.watch(requestsRepositoryProvider);
  return _isStaff(ref) ? repo.staffList(status: status) : repo.mine();
});

final requestProvider = FutureProvider.family<LeadRequest, String>((ref, id) {
  final repo = ref.watch(requestsRepositoryProvider);
  return _isStaff(ref) ? repo.staffOne(id) : repo.mineOne(id);
});

/// Mensajes de una solicitud (cliente ↔ asesor).
final requestMessagesProvider = FutureProvider.family<List<RequestMessage>, String>((ref, id) {
  return ref.watch(requestsRepositoryProvider).messages(id, staff: _isStaff(ref));
});

/// Brokers a quienes administración puede asignar una solicitud.
final assignableBrokersProvider = FutureProvider<List<({String id, String name})>>((ref) => ref.watch(requestsRepositoryProvider).brokers());

final requestActionsProvider = Provider<RequestActions>(RequestActions.new);

class RequestActions {
  RequestActions(this._ref);

  final Ref _ref;

  RequestsRepository get _repo => _ref.read(requestsRepositoryProvider);

  Future<void> sendMessage(String id, String body) async {
    final staff = _ref.read(sessionProvider).value?.isStaff ?? false;
    await _repo.send(id, body, staff: staff);
    _ref.invalidate(requestMessagesProvider(id));
    _ref.invalidate(requestProvider(id));
    _ref.invalidate(requestsProvider);
  }

  Future<LeadRequest> create({
    required String reason,
    String? message,
    required Map<String, Object?> payload,
    String? propertySlug,
    String? propertyCode,
    String? preferredDate,
    String? preferredTime,
  }) async {
    final r = await _repo.create(
        reason: reason, message: message, payload: payload, propertySlug: propertySlug, propertyCode: propertyCode, preferredDate: preferredDate, preferredTime: preferredTime);
    _ref.invalidate(requestsProvider);
    // Con día y hora también se agenda la cita
    _ref.invalidate(appointmentsProvider);
    _ref.invalidate(activeAppointmentProvider);
    return r;
  }

  Future<void> respond(String id, String response) => _after(id, _repo.update(id, response: response));
  Future<void> setStatus(String id, String status) => _after(id, _repo.update(id, status: status));
  Future<void> propose(String id, String propertyId, {String? note}) => _after(id, _repo.propose(id, propertyId, note: note));
  Future<void> unpropose(String id, String proposalId) => _after(id, _repo.unpropose(id, proposalId));

  /// Agenda la visita desde la solicitud: la cita aparece en «Citas» como por confirmar.
  Future<String> schedule(String id, {required String propertyId, required DateTime at, String? note}) async {
    final code = await _repo.schedule(id, propertyId: propertyId, at: at, note: note);
    await _after(id, Future.value());
    _ref.invalidate(appointmentsProvider);
    return code;
  }

  /// Solo administración: asigna el broker (la cita, si hay, pasa a él).
  Future<void> assign(String id, String brokerId) async {
    await _after(id, _repo.assign(id, brokerId));
    _ref.invalidate(appointmentsProvider);
  }

  /// Solo administración: borra la solicitud (las citas se conservan).
  Future<void> remove(String id) async {
    await _repo.remove(id);
    _ref.invalidate(requestsProvider);
    _ref.invalidate(staffDashboardProvider);
  }

  Future<void> _after(String id, Future<void> action) async {
    await action;
    _ref.invalidate(requestProvider(id));
    _ref.invalidate(requestsProvider);
    _ref.invalidate(staffDashboardProvider);
  }
}
