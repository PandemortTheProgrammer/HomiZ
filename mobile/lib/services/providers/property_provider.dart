import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';
import '../../models/property_models.dart';
import '../repositories/property_repository.dart';

final propertyDetailProvider = FutureProvider.family<PropertyDetail, String>((ref, id) => ref.watch(propertyRepositoryProvider).get(id));

final dossierProvider = FutureProvider.family<Dossier, String>((ref, id) => ref.watch(propertyRepositoryProvider).dossier(id));

final propertyBySlugProvider = FutureProvider.family<PropertyDetail?, String>((ref, slug) => ref.watch(propertyRepositoryProvider).bySlug(slug));

final catalogProvider =FutureProvider<List<PropertyDetail>>((ref) => ref.watch(propertyRepositoryProvider).catalog());

/// Todo el inventario: quien atiende una solicitud puede proponer o agendar cualquier casa, no solo las suyas.
final allHousesProvider = FutureProvider<List<PropertyDetail>>((ref) {
  ref.watch(sessionProvider.select((s) => s.value?.id));
  return ref.watch(propertyRepositoryProvider).inventory(brokerId: null, q: '');
});

/// Casas del personal. Propietario: todo el inventario. Los demás: las suyas y las disponibles
/// (las pueden ver, proponer y agendar; expediente y pagos los lleva el administrador que tiene la casa). [q] busca por nombre o clave.
final inventoryProvider = FutureProvider.family<List<PropertyDetail>, String>((ref, q) async {
  final user = ref.watch(sessionProvider).value;
  final all = await ref.watch(propertyRepositoryProvider).inventory(brokerId: null, q: q);
  if (user == null || user.isOwner) return all;
  return all.where((h) => h.broker?.id == user.id || (h.visibility == 'publicada' && (h.status == 'disponible' || h.status == 'reservada'))).toList();
});
