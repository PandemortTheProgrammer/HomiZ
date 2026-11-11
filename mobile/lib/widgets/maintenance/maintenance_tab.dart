import 'package:flutter/material.dart';

import '../common/en_construccion.dart';

/// Temporal: la fase siguiente reemplaza este archivo por la versión completa.
class MaintenanceTab extends StatelessWidget {
  const MaintenanceTab({super.key, required this.propertyId});
  final String propertyId;

  @override
  Widget build(BuildContext context) => const EnConstruccion(titulo: 'Mantenimiento', enPestana: true);
}
