import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../../services/utils/maps.dart';
import '../common/contact_actions.dart';
import '../common/initials_avatar.dart';
import '../common/states.dart';
import '../../models/property_models.dart';
import '../../services/providers/property_provider.dart';
import 'property_widgets.dart';

/// Pantalla 7 · Resumen: foto, ubicación, características y vigencia del contrato.
class SummaryTab extends ConsumerWidget {
  const SummaryTab({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dossier = ref.watch(dossierProvider(propertyId));
    // La foto sale de la ficha (URL firmada); si falla se muestra el recuadro gris.
    final photos = ref.watch(propertyDetailProvider(propertyId)).value?.photoUrls ?? const <String>[];
    return switch (dossier) {
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(propertyDetailProvider(propertyId));
            ref.invalidate(dossierProvider(propertyId));
            await ref.read(dossierProvider(propertyId).future);
          },
          child: SummaryView(dossier: value, photoUrls: photos),
        ),
      AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(dossierProvider(propertyId))),
      _ => const LoadingState(items: 2, itemHeight: 180),
    };
  }
}

class SummaryView extends StatelessWidget {
  const SummaryView({super.key, required this.dossier, this.photoUrls = const []});

  final Dossier dossier;
  final List<String> photoUrls;

  static String contractText(DossierContract? c) {
    if (c == null) return 'Aún no hay un contrato registrado para esta casa.';
    final rent = Fmt.money(c.monthlyRent);
    if (c.status != 'active') return 'El contrato finalizó el ${Fmt.shortDate(c.endDate)}.';
    return 'El contrato está vigente hasta ${Fmt.longDate(c.endDate)}. La renta es de $rent al mes y se paga el día ${c.paymentDay} de cada mes.';
  }

  @override
  Widget build(BuildContext context) {
    final p = dossier.property;
    final location = [p.city ?? 'Cancún', p.zone].whereType<String>().join(', ');
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      children: [
        PropertyGallery(urls: photoUrls, height: 210, title: p.name, overlay: HeroCaption(title: p.name, location: location)),
        const SizedBox(height: AppSpacing.lg),
        FeatureRow(rec: p.rec, banos: p.banos, amenities: p.amenities),
        const SizedBox(height: AppSpacing.lg),
        Text(contractText(dossier.contract), style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
        if ((p.address ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(p.address!, style: AppTextStyles.secondary),
          const SizedBox(height: AppSpacing.sm),
          // Mapa para llegar a la casa (el broker lo usa para las visitas y el mantenimiento)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => openMap(context, address: [p.address, location].join(', '), label: p.name),
              icon: const Icon(Icons.directions_outlined),
              label: const Text('Cómo llegar'),
            ),
          ),
        ],
        // Inquilino y asesor: la API solo los envía al personal.
        if (dossier.tenant case final t?) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Inquilino', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          _ContactCard(name: t.name, detail: [t.phone ?? 'Sin teléfono', t.email ?? 'Sin correo'].join('\n'), phone: t.phone, email: t.email),
        ],
        if (dossier.tenant != null && p.broker?.name != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Asesor responsable', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          // Sin teléfono: es el propio personal; para contactar está el inquilino
          _ContactCard(name: p.broker!.name!),
        ] else if (dossier.tenant == null && dossier.broker != null) ...[
          // Inquilino: contacto mutuo con su asesor
          const SizedBox(height: AppSpacing.xl),
          Text('Tu asesor', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          _ContactCard(
            name: dossier.broker!.name,
            detail: [dossier.broker!.phone, dossier.broker!.email].whereType<String>().join('\n'),
            phone: dossier.broker!.phone,
            email: dossier.broker!.email,
          ),
        ],
        if (dossier.utilities case final u? when u.electricity != null || u.water != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Servicios de agua y luz', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.xs),
          Text('Consulta tus recibos en la app de cada compañía con tu número. Te lo recordamos el día ${u.reminderDay} de cada mes.',
              style: AppTextStyles.secondary.copyWith(fontSize: 13)),
          const SizedBox(height: AppSpacing.sm),
          if (u.electricity case final e?) _UtilityCard(icon: Icons.bolt_outlined, label: 'Luz', service: e),
          if (u.electricity != null && u.water != null) const SizedBox(height: AppSpacing.sm),
          if (u.water case final w?) _UtilityCard(icon: Icons.water_drop_outlined, label: 'Agua', service: w),
        ],
      ],
    );
  }
}

/// Número de servicio con «Copiar» y el enlace a la compañía (CFE Contigo, Aguakan).
class _UtilityCard extends StatelessWidget {
  const _UtilityCard({required this.icon, required this.label, required this.service});

  final IconData icon;
  final String label;
  final UtilityService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.cardAll, border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label · ${service.company}', style: AppTextStyles.cardTitle),
                SelectableText(service.serviceNumber, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
                if (service.app != null) Text('Consúltalo en la app ${service.app}', style: AppTextStyles.secondary.copyWith(fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copiar número de $label',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: service.serviceNumber));
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Número de ${service.company} copiado.')));
            },
          ),
          if (service.url != null)
            IconButton(
              tooltip: 'Abrir ${service.company}',
              icon: const Icon(Icons.open_in_new_rounded),
              onPressed: () => launchUrl(Uri.parse(service.url!), mode: LaunchMode.externalApplication),
            ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.name, this.detail, this.phone, this.email});

  final String name;
  final String? detail;
  final String? phone;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.cardAll, border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: name, size: 36),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.cardTitle),
                    if (detail != null && detail!.isNotEmpty) Text(detail!, style: AppTextStyles.secondary),
                  ],
                ),
              ),
            ],
          ),
          if (phone != null || email != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ContactActions(phone: phone, email: email),
          ],
        ],
      ),
    );
  }
}
