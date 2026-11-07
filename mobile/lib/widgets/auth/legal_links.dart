import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/network/api_client.dart';

/// Dónde están el aviso de privacidad y «Eliminar mi cuenta» en el sitio (GET /public/legal).
typedef LegalLinks = ({String privacyUrl, String deleteAccountUrl, String version});

final legalLinksProvider = FutureProvider<LegalLinks>((ref) async {
  final res = await ref.watch(dioProvider).get<Map<String, dynamic>>('/public/legal');
  final d = res.data ?? const {};
  return (
    privacyUrl: d['privacyUrl'] as String? ?? '',
    deleteAccountUrl: d['deleteAccountUrl'] as String? ?? '',
    version: d['privacyVersion'] as String? ?? '',
  );
});

/// Abre el aviso de privacidad en el navegador.
Future<void> openPrivacyNotice(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final links = await ref.read(legalLinksProvider.future);
    if (links.privacyUrl.isEmpty || !await launchUrl(Uri.parse(links.privacyUrl), mode: LaunchMode.externalApplication)) {
      messenger.showSnackBar(const SnackBar(content: Text('No pudimos abrir el aviso de privacidad.')));
    }
  } on DioException {
    messenger.showSnackBar(const SnackBar(content: Text('No pudimos abrir el aviso de privacidad. Revisa tu conexión.')));
  }
}

/// «Acepto el aviso de privacidad» con el enlace para leerlo (registro y formularios).
class PrivacyConsentField extends ConsumerWidget {
  const PrivacyConsentField({super.key, required this.value, required this.onChanged, this.error, this.color});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? error;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = TextStyle(color: color, fontSize: 13);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: value, onChanged: (v) => onChanged(v ?? false), side: color == null ? null : BorderSide(color: color!)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text.rich(
                  TextSpan(style: style, children: [
                    const TextSpan(text: 'Acepto el '),
                    TextSpan(
                      text: 'aviso de privacidad',
                      style: style.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()..onTap = () => openPrivacyNotice(context, ref),
                    ),
                    const TextSpan(text: ' y el uso de mis datos para atender mis solicitudes, citas y, si rento, mi contrato y mis pagos.'),
                  ]),
                ),
              ),
            ),
          ],
        ),
        if (error != null) Padding(padding: const EdgeInsets.only(left: 12), child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12))),
      ],
    );
  }
}
