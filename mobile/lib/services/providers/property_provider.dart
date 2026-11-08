import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';
import '../../models/property_models.dart';
import '../repositories/property_repository.dart';

final propertyDetailProvider = FutureProvider.family<PropertyDetail, String>((ref, id) => ref.watch(propertyRepositoryProvider).get(id));

final dossierProvider = FutureProvider.family<Dossier, String>((ref, id) => ref.watch(propertyRepositoryProvider).dossier(id));

final propertyBySlugProvider = FutureProvider.family<PropertyDetail?, String>((ref, slug) => ref.watch(propertyRepositoryProvider).bySlug(slug));

final catalogProvider =FutureProvider<List<PropertyDetail>>((ref) => ref.watch(propertyRepositoryProvider).catalog());

/// Casas del personal: el broker ve las suyas; la administración, todo el inventario. [q] busca por nombre o clave.
final inventoryProvider = FutureProvider.family<List<PropertyDetail>, String>((ref, q) {
  final user = ref.watch(sessionProvider).value;
  final onlyMine = user != null && !user.isAdmin && user.isBroker;
  return ref.watch(propertyRepositoryProvider).inventory(brokerId: onlyMine ? user.id : null, q: q);
});
