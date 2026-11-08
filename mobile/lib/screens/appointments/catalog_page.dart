import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/states.dart';
import '../../models/property_models.dart';
import '../../services/providers/property_provider.dart';
import '../../widgets/property/property_widgets.dart';

/// «Te mostramos más opciones»: todas las propiedades activas (publicadas y disponibles) en tarjetas,
/// con filtro de renta o venta. Tocar una abre su ficha para agendar (o cambiar) la cita.
class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String _op = '';

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Todas nuestras propiedades')),
      body: switch (catalog) {
        AsyncData(:final value) when value.isEmpty => const EmptyState(
          icon: Icons.home_work_outlined,
          title: 'No hay propiedades disponibles',
          message: 'Vuelve pronto: publicamos propiedades nuevas cada semana.',
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(catalogProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screen),
            itemCount: _list(value).length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, i) {
              final list = _list(value);
              if (i == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${list.length} ${list.length == 1 ? 'propiedad disponible' : 'propiedades disponibles'}', style: AppTextStyles.secondary),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '', label: Text('Todas')),
                        ButtonSegment(value: 'renta', label: Text('Renta')),
                        ButtonSegment(value: 'venta', label: Text('Venta')),
                      ],
                      selected: {_op},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) => setState(() => _op = s.first),
                    ),
                  ],
                );
              }
              final p = list[i - 1];
              return Semantics(
                button: true,
                label: '${p.name}, ${p.zone ?? ''}, ${Fmt.money(p.price)}',
                child: InkWell(
                  borderRadius: AppRadius.cardAll,
                  onTap: () => context.push('/appointments/catalog/${p.id}'),
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PropertyHero(
                          url: p.coverUrl,
                          height: 160,
                          overlay: HeroCaption(title: p.name, location: p.zone),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          [p.type ?? 'Casa', p.operation == 'venta' ? 'En venta' : 'En renta', if (p.m2 != null) '${p.m2!.round()} m²', p.petsAllowed ? 'Acepta mascotas' : 'Sin mascotas'].join(' · '),
                          style: AppTextStyles.secondary.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: FeatureRow(rec: p.rec, banos: p.banos),
                            ),
                            Text('${Fmt.money(p.price)}${p.operation == 'renta' ? '/mes' : ''}', style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(catalogProvider)),
        _ => const LoadingState(items: 3, itemHeight: 200),
      },
    );
  }

  List<PropertyDetail> _list(List<PropertyDetail> all) => _op.isEmpty ? all : all.where((p) => p.operation == _op).toList();
}
