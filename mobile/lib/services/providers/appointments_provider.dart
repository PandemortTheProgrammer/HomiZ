import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/formatters.dart';
import 'session_provider.dart';
import 'dashboard_provider.dart';
import '../../models/appointment.dart';
import '../repositories/appointments_repository.dart';

/// Citas del cliente: primero las próximas (de la más cercana a la más lejana) y después las pasadas.
final appointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  ref.watch(sessionProvider.select((s) => s.value?.id));
  final all = await ref.watch(appointmentsRepositoryProvider).list();
  final now = Fmt.now();
  final upcoming = all.where((a) => a.scheduledAt.isAfter(now)).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  final past = all.where((a) => !a.scheduledAt.isAfter(now)).toList()..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  return [...upcoming, ...past];
});

final appointmentProvider = FutureProvider.family<Appointment, String>((ref, id) => ref.watch(appointmentsRepositoryProvider).get(id));

/// La cita vigente del cliente (una a la vez). Se vuelve a leer cuando cambia la lista de citas.
final activeAppointmentProvider = FutureProvider<Appointment?>((ref) async {
  ref.watch(appointmentsProvider);
  return ref.watch(appointmentsRepositoryProvider).active();
});

/// Chat de una cita.
final appointmentMessagesProvider = AsyncNotifierProvider.family<AppointmentMessagesController, List<AppointmentMessage>, String>(AppointmentMessagesController.new);

class AppointmentMessagesController extends AsyncNotifier<List<AppointmentMessage>> {
  AppointmentMessagesController(this.appointmentId);

  final String appointmentId;

  @override
  Future<List<AppointmentMessage>> build() => ref.watch(appointmentsRepositoryProvider).messages(appointmentId);

  /// Los errores se propagan para que la pantalla conserve el texto y muestre el mensaje.
  Future<void> send(String body) async {
    final updated = await ref.read(appointmentsRepositoryProvider).sendMessage(appointmentId, body);
    state = AsyncData(updated);
  }
}

/// Acciones sobre citas que refrescan la lista, el detalle y el panel.
final appointmentActionsProvider = Provider<AppointmentActions>(AppointmentActions.new);

class AppointmentActions {
  AppointmentActions(this._ref);

  final Ref _ref;

  void _refresh(String id) {
    _ref.invalidate(appointmentsProvider);
    _ref.invalidate(appointmentProvider(id));
    _ref.invalidate(clientDashboardProvider);
    _ref.invalidate(staffDashboardProvider);
  }

  AppointmentsRepository get _repo => _ref.read(appointmentsRepositoryProvider);

  Future<void> cancel(String id, {String? reason}) async {
    await _repo.cancel(id, reason: reason);
    _refresh(id);
  }

  Future<void> confirm(String id) async {
    await _repo.confirm(id);
    _refresh(id);
  }

  Future<void> reject(String id, String reason) async {
    await _repo.reject(id, reason);
    _refresh(id);
  }

  Future<void> complete(String id) async {
    await _repo.complete(id);
    _refresh(id);
  }

  Future<void> reschedule(String id, DateTime scheduledAt, {String? reason}) async {
    await _repo.reschedule(id, scheduledAt, reason: reason);
    _refresh(id);
  }

  Future<Appointment> request({required String propertyId, required DateTime scheduledAt, String? note}) async {
    final a = await _repo.request(propertyId: propertyId, scheduledAt: scheduledAt, note: note);
    _refresh(a.id);
    return a;
  }
}
