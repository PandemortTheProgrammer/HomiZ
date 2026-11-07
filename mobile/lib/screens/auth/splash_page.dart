import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../widgets/common/auth_background.dart';
import '../../widgets/common/primary_button.dart';
import '../../services/providers/session_provider.dart';

/// Pantalla 1 · Bienvenida: logo sobre el degradado mientras se recupera la sesión.
/// Si no hay conexión muestra el mensaje y «Reintentar».
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final error = session.hasError && !session.isLoading ? ApiException.from(session.error!) : null;
    return Scaffold(
      body: AuthBackground(
        scrollable: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(header: true, child: Text('Homiz', style: AppTextStyles.brand)),
            const SizedBox(height: AppSpacing.xs),
            Text('by', style: AppTextStyles.body.copyWith(color: Colors.white70)),
            const SizedBox(height: AppSpacing.sm),
            const ZugarLogo(height: 48),
            const SizedBox(height: AppSpacing.xxxl),
            if (error == null)
              const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.6))
            else ...[
              Text(error.message, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: Colors.white)),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: 'Reintentar', variant: ButtonVariant.white, onPressed: () => ref.read(sessionProvider.notifier).retry()),
            ],
          ],
        ),
      ),
    );
  }
}
