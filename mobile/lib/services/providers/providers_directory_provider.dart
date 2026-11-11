import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/service_provider.dart';
import '../repositories/providers_repository.dart';

/// Directorio de proveedores activos; [q] busca por nombre, especialidad o zona.
final providersDirectoryProvider = FutureProvider.family<List<ServiceProvider>, String>((ref, q) => ref.watch(providersRepositoryProvider).list(q: q));
