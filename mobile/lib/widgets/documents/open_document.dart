import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/network/api_exception.dart';
import '../../services/repositories/documents_repository.dart';

/// Pide la URL firmada y abre el documento (PDF o imagen) en el visor del teléfono.
Future<void> openDocument(BuildContext context, WidgetRef ref, String documentId) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final url = await ref.read(documentsRepositoryProvider).downloadUrl(documentId);
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(const SnackBar(content: Text('No encontramos una aplicación para abrir el archivo.')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
  }
}
