import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Foto descargada de internet con el recuadro gris mientras carga o si falla.
///
/// En la versión web se dibuja con una etiqueta `<img>`, igual que el sitio: así las fotos del
/// almacenamiento (Cloudflare R2) se ven aunque la app se abra desde otro dominio, como el túnel.
/// En Android e iOS se guardan en caché para no descargarlas otra vez.
class NetImage extends StatelessWidget {
  const NetImage(this.url, {super.key, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  static const _empty = ColoredBox(color: AppColors.placeholderBox, child: SizedBox.expand());

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        url,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (_, child, progress) => progress == null ? child : _empty,
        errorBuilder: (_, _, _) => _empty,
      );
    }
    return CachedNetworkImage(imageUrl: url, fit: fit, placeholder: (_, _) => _empty, errorWidget: (_, _, _) => _empty);
  }
}
