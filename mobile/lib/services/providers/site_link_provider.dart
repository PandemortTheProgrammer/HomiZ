import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Datos con los que el sitio o un correo abren la app (versión web):
/// `?reset=<código>&email=<correo>` → «Crea tu contraseña» (cuenta creada sola o recuperación);
/// `?email=<correo>` → acceso con el correo ya escrito (la persona acaba de enviar un formulario del sitio);
/// `?empezar=1` (QR de «Cómo trabajamos» o de una casa sin llenar datos) → al entrar, «¿Qué quieres hacer?».
class SiteLink {
  const SiteLink({this.resetToken, this.email, this.start = false});

  factory SiteLink.fromUri(Uri uri) {
    final q = uri.queryParameters;
    final token = q['reset']?.trim();
    final email = q['email']?.trim().toLowerCase();
    return SiteLink(
      resetToken: token != null && RegExp(r'^[A-Za-z0-9_-]{16,200}$').hasMatch(token) ? token : null,
      email: email != null && RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(email) ? email : null,
      start: q['empezar'] == '1',
    );
  }

  final String? resetToken;
  final String? email;

  /// Entró por un QR sin haber llenado datos: se le pregunta qué quiere hacer
  final bool start;

  /// Llegó desde el sitio o desde un correo: al entrar se muestran sus solicitudes.
  bool get fromSite => resetToken != null || email != null;
}

final siteLinkProvider = NotifierProvider<SiteLinkController, SiteLink>(SiteLinkController.new);

class SiteLinkController extends Notifier<SiteLink> {
  @override
  SiteLink build() => SiteLink.fromUri(Uri.base);

  /// Ya se usó (se creó la contraseña o ya se mostraron sus solicitudes).
  void clear() => state = const SiteLink();
}
