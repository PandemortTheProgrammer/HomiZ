import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/theme/app_spacing.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/cards.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/segmented_tabs.dart';
import '../../widgets/common/states.dart';
import '../../widgets/common/status_badge.dart';
import '../../services/providers/session_provider.dart';
import '../../services/repositories/requests_repository.dart';
import '../../services/providers/requests_provider.dart';

/// Insignia del estado: Recibida · En seguimiento · Cerrada.
StatusBadge requestBadge(LeadRequest r) => StatusBadge(
      kind: switch (r.status) { 'nuevo' => BadgeKind.pending, 'en_seguimiento' => BadgeKind.confirmed, _ => BadgeKind.neutral },
      label: r.statusLabel,
    );

/// «Mis solicitudes» (cliente) o «Solicitudes» del sitio y la app (personal con leads.manage).
/// Aquí llegan la respuesta del asesor y las casas que propone, en lugar del correo.
class RequestsPage extends ConsumerStatefulWidget {
  const RequestsPage({super.key});

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  static const _filters = ['nuevo', 'en_seguimiento', 'cerrado', null];
  static const _labels = ['Nuevas', 'En seguimiento', 'Cerradas', 'Todas'];
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(sessionProvider.select((s) => s.value?.isStaff ?? false));
    // Administración ve primero las que llegaron sin broker (las asigna ella)
    final admin = ref.watch(sessionProvider.select((s) => s.value?.isAdmin ?? false));
    final filters = [if (admin) 'sin_asignar', ..._filters];
    final labels = [if (admin) 'Sin asignar', ..._labels];
    final status = staff ? filters[_filter.clamp(0, filters.length - 1)] : null;
    final list = ref.watch(requestsProvider(status));
    return Scaffold(
      appBar: AppBar(title: Text(staff ? 'Solicitudes' : 'Mis solicitudes')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(requestsProvider(status).future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.screen, AppSpacing.xl),
          children: [
            InfoNotice(
              text: staff
                  ? 'Lo que piden en el sitio y en la app. Contesta y propón casas: al cliente le llega aquí, en su app.'
                  : 'Rentar, comprar, publicar tu propiedad o lo que necesites: cuéntanos aquí. Tu asesor te contestará en la app y te avisaremos con una notificación.',
            ),
            const SizedBox(height: AppSpacing.md),
            if (staff) ...[
              SegmentedTabs(tabs: labels, selected: _filter.clamp(0, filters.length - 1), onChanged: (i) => setState(() => _filter = i)),
              const SizedBox(height: AppSpacing.md),
            ] else ...[
              PrimaryButton(label: 'Nueva solicitud', icon: Icons.add_home_outlined, onPressed: () => context.push('/home/requests/new')),
              const SizedBox(height: AppSpacing.md),
            ],
            ...switch (list) {
              AsyncData(:final value) when value.isEmpty => [
                  EmptyState(
                    icon: Icons.mark_email_unread_outlined,
                    title: staff ? 'Sin solicitudes' : 'Aún no tienes solicitudes',
                    message: staff ? 'No hay solicitudes con este filtro.' : 'Toca «Nueva solicitud» y dinos qué necesitas.',
                  ),
                ],
              AsyncData(:final value) => [
                  for (final r in value) ...[
                    ListCard(
                      title: staff ? '${r.name ?? ''} · ${r.folio}' : '${r.reasonLabel} · ${r.folio}',
                      subtitle: [
                        if (staff) r.reasonLabel,
                        if (staff) r.brokerName ?? 'Sin broker asignado',
                        r.propertyName ?? r.summary,
                        Fmt.dayMonthShort(r.createdAt),
                        if (r.proposalCount > 0) '${r.proposalCount} ${r.proposalCount == 1 ? 'casa propuesta' : 'casas propuestas'}' else if (r.response != null) 'Respondida',
                      ].where((s) => s.isNotEmpty).join(' · '),
                      trailing: requestBadge(r),
                      // Dentro de la misma pestaña: /requests/:id (personal) o /home/requests/:id
                      onTap: () => context.push('${GoRouterState.of(context).matchedLocation}/${r.id}'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              AsyncError(:final error) => [ErrorState(error: error, onRetry: () => ref.invalidate(requestsProvider(status)))],
              _ => [const SizedBox(height: 260, child: LoadingState(items: 3))],
            },
          ],
        ),
      ),
    );
  }
}
