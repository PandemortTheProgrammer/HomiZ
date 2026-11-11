import 'package:flutter/material.dart';

import '../../widgets/common/en_construccion.dart';

/// Temporal: la fase siguiente reemplaza este archivo por la versión completa.
class NewReportPage extends StatelessWidget {
  const NewReportPage({super.key, required this.propertyId});
  final String propertyId;

  @override
  Widget build(BuildContext context) => const EnConstruccion(titulo: 'Nuevo reporte');
}
