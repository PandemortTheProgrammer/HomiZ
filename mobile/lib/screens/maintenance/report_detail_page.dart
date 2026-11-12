import 'package:flutter/material.dart';

import '../../widgets/common/en_construccion.dart';

/// Temporal: la fase siguiente reemplaza este archivo por la versión completa.
class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key, required this.reportId});
  final String reportId;

  @override
  Widget build(BuildContext context) => const EnConstruccion(titulo: 'Reporte');
}
