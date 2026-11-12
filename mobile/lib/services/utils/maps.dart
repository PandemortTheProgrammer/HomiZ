import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre la app de mapas del teléfono (geo:) en el punto o, si no lo hay, buscando la dirección.
/// Si no hay app de mapas, abre OpenStreetMap en el navegador.
Future<void> openMap(BuildContext context, {double? lat, double? lng, String? address, required String label}) async {
  final hasPoint = lat != null && lng != null;
  final q = Uri.encodeComponent(hasPoint ? '$lat,$lng($label)' : address ?? label);
  final geo = Uri.parse(hasPoint ? 'geo:$lat,$lng?q=$q' : 'geo:0,0?q=$q');
  final web = Uri.parse(hasPoint
      ? 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng'
      : 'https://www.openstreetmap.org/search?query=${Uri.encodeComponent(address ?? label)}');
  final messenger = ScaffoldMessenger.of(context);
  if (!await launchUrl(geo, mode: LaunchMode.externalApplication) && !await launchUrl(web, mode: LaunchMode.externalApplication)) {
    messenger.showSnackBar(const SnackBar(content: Text('No pudimos abrir el mapa.')));
  }
}
