import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../common/cards.dart';
import '../common/confirm_dialog.dart';
import '../common/primary_button.dart';
import '../common/states.dart';
import '../common/status_badge.dart';
import '../../services/providers/session_provider.dart';
import '../documents/document_sheet.dart';
import '../documents/open_document.dart';
import '../../models/property_models.dart';
import '../../services/providers/property_provider.dart';

/// Pantalla 8 · Expediente: contrato, depósito, ficha de entrega y documentos (solo los visibles para el cliente).
/// Con [staff], todos los documentos y las acciones de su rol (subir, editar, mostrar/ocultar, eliminar).
class DossierTab extends ConsumerWidget {
  const DossierTab({super.key, required this.propertyId, this.staff = false});

  final String propertyId;
  final bool staff;

  Future<void> _open(BuildContext context, WidgetRef ref, Dossier dossier, DossierSection section) async {
    if (section.documentIds.length == 1) return openDocument(context, ref, section.documentIds.single);
    final docs = dossier.documents.where((d) => section.documentIds.contains(d.id)).toList();
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.sm), child: Text(section.title, style: AppTextStyles.pageTitle)),
            for (final d in docs)
              ListTile(
                leading: Icon(d.mime == 'application/pdf' ? Icons.picture_as_pdf_outlined : Icons.image_outlined),
                title: Text(d.name),
                subtitle: d.description == null ? null : Text(d.description!),
                onTap: () => Navigator.pop(context, d.id),
              ),
          ],
        ),
      ),
    );
    if (chosen != null && context.mounted) await openDocument(context, ref, chosen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (staff) return StaffDossier(propertyId: propertyId);
    final dossier = ref.watch(dossierProvider(propertyId));
    return switch (dossier) {
      AsyncData(:final value) when value.sections.isEmpty => const EmptyState(
          icon: Icons.folder_open_outlined,
          title: 'Tu expediente está vacío',
          message: 'Aquí aparecerán tu contrato, el depósito y la ficha de entrega cuando la inmobiliaria los suba.',
        ),
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(dossierProvider(propertyId).future),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
            itemCount: value.sections.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final s = value.sections[i];
              return ListCard(
                title: s.title,
                subtitle: s.subtitle,
                trailing: s.documentIds.isEmpty
                    ? null
                    : StatusBadge(kind: BadgeKind.view, onTap: () => _open(context, ref, value, s)),
              );
            },
          ),
        ),
      AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(dossierProvider(propertyId))),
      _ => const LoadingState(),
    };
  }
}

/// Expediente del personal: todos los documentos, si el cliente los ve, y lo que su rol le permite.
/// Broker (documents.manage): sube, edita y muestra u oculta. Administración (documents.delete): además elimina.
class StaffDossier extends ConsumerWidget {
  const StaffDossier({super.key, required this.propertyId});

  final String propertyId;

  Future<void> _actions(BuildContext context, WidgetRef ref, DossierDocument d) async {
    final user = ref.read(sessionProvider).value;
    final manage = user?.can('documents.manage') ?? false;
    final remove = user?.can('documents.delete') ?? false;
    final visible = d.visibleToClient ?? false;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.sm), child: Text(d.name, style: AppTextStyles.pageTitle)),
            ListTile(leading: const Icon(Icons.visibility_outlined), title: const Text('Ver documento'), onTap: () => Navigator.pop(context, 'view')),
            if (manage) ...[
              ListTile(
                leading: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                title: Text(visible ? 'Ocultar al cliente' : 'Mostrar al cliente'),
                onTap: () => Navigator.pop(context, 'toggle'),
              ),
              ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Editar nombre y descripción'), onTap: () => Navigator.pop(context, 'edit')),
            ],
            if (remove)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Eliminar documento', style: TextStyle(color: AppColors.danger)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(documentActionsProvider);
    Future<void> run(Future<void> Function() f, String done) async {
      try {
        await f();
        messenger.showSnackBar(SnackBar(content: Text(done)));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
      }
    }

    switch (chosen) {
      case 'view':
        await openDocument(context, ref, d.id);
      case 'toggle':
        await run(() => actions.update(propertyId, d.id, visibleToClient: !visible), visible ? '«${d.name}» ya no aparece en la app del cliente.' : '«${d.name}» ahora aparece en la app del cliente.');
      case 'edit':
        if (await showDocumentSheet(context, propertyId: propertyId, document: d)) messenger.showSnackBar(SnackBar(content: Text('Se actualizó «${d.name}».')));
      case 'delete':
        final ok = await showConfirmDialog(
          context,
          title: '¿Eliminar «${d.name}»?',
          message: 'El archivo se borra del expediente y del almacenamiento. Queda registrado en el historial quién lo eliminó. No se puede deshacer.',
          cancelLabel: 'Conservar',
          confirmLabel: 'Sí, eliminar',
          destructive: true,
        );
        if (ok) await run(() => actions.delete(propertyId, d.id), 'Se eliminó «${d.name}» del expediente.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dossier = ref.watch(dossierProvider(propertyId));
    final user = ref.watch(sessionProvider).value;
    final manage = user?.can('documents.manage') ?? false;
    final remove = user?.can('documents.delete') ?? false;
    return switch (dossier) {
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(dossierProvider(propertyId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
            children: [
              InfoNotice(
                text: remove
                    ? 'Puedes subir, editar, ocultar y eliminar documentos. Toca uno para ver las opciones.'
                    : manage
                        ? 'Puedes subir, editar y ocultar documentos de tus casas; eliminarlos lo hace administración.'
                        : 'Solo consulta.',
              ),
              const SizedBox(height: AppSpacing.md),
              if (manage) ...[
                PrimaryButton(
                  label: 'Subir documento',
                  icon: Icons.upload_file_outlined,
                  variant: ButtonVariant.outline,
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (await showDocumentSheet(context, propertyId: propertyId)) messenger.showSnackBar(const SnackBar(content: Text('Documento agregado al expediente.')));
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (value.documents.isEmpty)
                const EmptyState(icon: Icons.folder_open_outlined, title: 'Expediente vacío', message: 'Sube el contrato, el depósito o la ficha de entrega.')
              else
                for (final d in value.documents) ...[
                  ListCard(
                    title: d.name,
                    subtitle: [documentTypes[d.type] ?? d.type, if (d.description != null) d.description!].join(' · '),
                    onTap: () => _actions(context, ref, d),
                    trailing: StatusBadge(kind: (d.visibleToClient ?? false) ? BadgeKind.paid : BadgeKind.neutral, label: (d.visibleToClient ?? false) ? 'Visible' : 'Solo personal'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
            ],
          ),
        ),
      AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(dossierProvider(propertyId))),
      _ => const LoadingState(),
    };
  }
}
