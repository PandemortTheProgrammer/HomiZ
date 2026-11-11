import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Temporal: ocupa el lugar de las pantallas de las fases 10 a 12. En la Fase 12 se borra.
class EnConstruccion extends StatelessWidget {
  const EnConstruccion({super.key, required this.titulo, this.enPestana = false});

  final String titulo;
  final bool enPestana;

  @override
  Widget build(BuildContext context) {
    final aviso = Center(child: Text('$titulo llega en la siguiente fase.', style: AppTextStyles.secondary, textAlign: TextAlign.center));
    return enPestana ? aviso : Scaffold(appBar: AppBar(title: Text(titulo)), body: aviso);
  }
}

