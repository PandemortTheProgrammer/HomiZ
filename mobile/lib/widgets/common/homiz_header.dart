import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/providers/session_provider.dart';
import '../../services/providers/notifications_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import 'auth_background.dart';

/// Encabezado de las pestañas: «Hola, Laura», campana con contador y acceso al perfil.
/// Debajo, el subtítulo de la sección en azul («Mi propiedad»).
class HomizHeader extends ConsumerWidget {
  const HomizHeader({super.key, this.section});

  final String? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(sessionProvider.select((s) => s.value?.name)) ?? '';
    final unread = ref.watch(unreadCountProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.lg, AppSpacing.sm, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ZugarIcon(size: 30),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(name.isEmpty ? 'Hola' : 'Hola, ${Fmt.firstName(name)}', style: AppTextStyles.greeting, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              IconButton(
                tooltip: unread > 0 ? 'Notificaciones, $unread sin leer' : 'Notificaciones',
                onPressed: () => context.push('/notifications'),
                icon: Badge(
                  isLabelVisible: unread > 0,
                  backgroundColor: AppColors.danger,
                  label: Text(unread > 99 ? '99+' : '$unread'),
                  child: const Icon(Icons.notifications_none_rounded, size: 28, color: AppColors.navIcon),
                ),
              ),
              IconButton(
                tooltip: 'Mi perfil',
                onPressed: () => context.push('/profile'),
                icon: const Icon(Icons.person_outline_rounded, size: 28, color: AppColors.navIcon),
              ),
            ],
          ),
          if (section != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(section!, style: AppTextStyles.sectionTitle),
          ],
        ],
      ),
    );
  }
}
