import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';
import '../../models/client_dashboard.dart';
import '../../models/staff_dashboard.dart';
import '../repositories/dashboard_repository.dart';

/// Panel del cliente. Se recarga al cambiar de usuario o al invalidarlo tras una acción.
final clientDashboardProvider = FutureProvider<ClientDashboard>((ref) {
  ref.watch(sessionProvider.select((s) => s.value?.id));
  return ref.watch(dashboardRepositoryProvider).client();
});

/// Panel del personal: pendientes de sus casas (broker) o de toda la inmobiliaria (administración).
final staffDashboardProvider = FutureProvider<StaffDashboard>((ref) {
  ref.watch(sessionProvider.select((s) => s.value?.id));
  return ref.watch(dashboardRepositoryProvider).staff();
});

/// Casa que renta el cliente: la del contrato vigente (panel) o la de su expediente.
final myPropertyIdProvider = FutureProvider<String?>((ref) async {
  final fromProfile = ref.watch(sessionProvider.select((s) => s.value?.client?.propertyId));
  final dashboard = await ref.watch(clientDashboardProvider.future);
  return dashboard.property?.id ?? fromProfile;
});
