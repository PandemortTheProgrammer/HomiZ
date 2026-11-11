import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/states.dart';
import '../../services/providers/session_provider.dart';
import '../../models/property_models.dart';
import '../../services/providers/property_provider.dart';
import 'property_widgets.dart';

/// Casas a cargo del broker (o todo el inventario para la administración), con búsqueda.
class StaffPropertiesList extends ConsumerStatefulWidget {
  const StaffPropertiesList({super.key});

  @override
  ConsumerState<StaffPropertiesList> createState() => _StaffPropertiesListState();
}

class _StaffPropertiesListState extends ConsumerState<StaffPropertiesList> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(inventoryProvider(_q));
    final user = ref.watch(sessionProvider).value;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.md),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => setState(() => _q = v.trim()),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, clave o zona',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _q.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(() {
                        _search.clear();
                        _q = '';
                      }),
                    ),
            ),
          ),
        ),
        Expanded(
          child: switch (list) {
            AsyncData(:final value) when value.isEmpty => EmptyState(
                icon: Icons.apartment_outlined,
                title: _q.isEmpty ? 'Sin casas asignadas' : 'Sin resultados',
                message: _q.isEmpty ? 'Cuando la administración te asigne casas aparecerán aquí.' : 'Prueba con otro nombre o la clave ZUG-###.',
              ),
            AsyncData(:final value) => RefreshIndicator(
                onRefresh: () => ref.refresh(inventoryProvider(_q).future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
                  itemCount: value.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final h = value[i];
                    // Sin administrarla, se consulta para proponerla; expediente y pagos los lleva su administrador
                    final manages = user?.manages(h.broker?.id) ?? false;
                    return StaffPropertyTile(property: h, showBroker: true, onTap: manages ? () => context.go('/property/${value[i].id}') : () => _showInfo(context, h));
                  },
                ),
              ),
            AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(inventoryProvider(_q))),
            _ => const LoadingState(),
          },
        ),
      ],
    );
  }
}

/// Casa de otro broker: los datos para proponerla o agendarla.
void _showInfo(BuildContext context, PropertyDetail h) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(h.name, style: AppTextStyles.pageTitle),
              const SizedBox(height: AppSpacing.xs),
              Text([h.code, h.zone].whereType<String>().join(' · '), style: AppTextStyles.secondary),
              const SizedBox(height: AppSpacing.md),
              Text('${Fmt.money(h.price)}${h.operation == 'renta' ? ' / mes' : ''}', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSpacing.xs),
              Text('${h.rec ?? 0} recámaras · ${h.banos ?? 0} baños', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.md),
              Text('La administra ${h.broker?.name ?? 'la inmobiliaria'}. Puedes proponerla y agendarla desde una solicitud; su expediente y sus pagos los lleva su administrador.', style: AppTextStyles.secondary),
            ],
          ),
        ),
      ),
    );

/// Fila de inventario: foto pequeña, nombre, clave, zona, precio, estado y (administración) broker.
class StaffPropertyTile extends StatelessWidget {
  const StaffPropertyTile({super.key, required this.property, required this.onTap, this.showBroker = false});

  final PropertyDetail property;
  final VoidCallback onTap;
  final bool showBroker;

  static String statusLabel(String? s) => switch (s) {
        'disponible' => 'Disponible',
        'reservada' => 'Reservada',
        'rentada' => 'Rentada',
        'vendida' => 'Vendida',
        'borrador' => 'Borrador',
        _ => s ?? '',
      };

  @override
  Widget build(BuildContext context) {
    final p = property;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll, side: const BorderSide(color: AppColors.divider)),
      child: InkWell(
        borderRadius: AppRadius.cardAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SizedBox(width: 84, child: PropertyHero(url: p.coverUrl, height: 72)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: AppTextStyles.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text([p.code, p.zone].whereType<String>().join(' · '), style: AppTextStyles.secondary),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${Fmt.money(p.price)}${p.operation == 'renta' ? '/mes' : ''} · ${statusLabel(p.status)}',
                      style: AppTextStyles.label.copyWith(color: AppColors.primary),
                    ),
                    if (showBroker && p.broker != null) Text('Asesor: ${p.broker!.name}', style: AppTextStyles.secondary),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
