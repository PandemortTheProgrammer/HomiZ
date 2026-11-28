import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/providers/session_provider.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/theme/app_spacing.dart';
import '../widgets/theme/app_text_styles.dart';

/// Pantalla temporal: ocupa el lugar de las que se agregan en fases siguientes. En la Fase 8 se borra.
class ProximamentePage extends ConsumerWidget {
  const ProximamentePage({super.key, required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conSesion = ref.watch(sessionProvider.select((s) => s.value != null));
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Esta pantalla se agrega en una fase siguiente.', textAlign: TextAlign.center, style: AppTextStyles.body),
            if (conSesion) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: 'Cerrar sesión', variant: ButtonVariant.danger, onPressed: () => ref.read(sessionProvider.notifier).logout()),
            ],
          ],
        ),
      ),
    );
  }
}
