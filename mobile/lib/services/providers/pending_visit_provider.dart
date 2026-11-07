import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Casa que el cliente eligió en el sitio de Zugar («Usar la app» abre la app con `?casa=<slug>`).
/// Se recuerda mientras se registra o inicia sesión; después se abre «Solicitar visita» de esa casa.
final pendingVisitProvider = NotifierProvider<PendingVisitController, String?>(PendingVisitController.new);

/// Lee `?casa=` de la dirección con la que se abrió la app (solo existe en la versión web).
String? visitSlugFromUri(Uri uri) {
  final slug = uri.queryParameters['casa']?.trim().toLowerCase();
  return slug != null && RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(slug) && slug.length <= 120 ? slug : null;
}

class PendingVisitController extends Notifier<String?> {
  @override
  String? build() => visitSlugFromUri(Uri.base);

  /// Ya se abrió la ficha de la casa: no se vuelve a redirigir.
  void clear() => state = null;
}
