import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/segmented_tabs.dart';
import '../../widgets/common/states.dart';
import '../../services/providers/session_provider.dart';
import '../../models/payment_models.dart';
import '../../services/providers/payments_provider.dart';
import '../../widgets/payments/note_actions_sheet.dart';
import '../../widgets/payments/payments_tab.dart';

/// Personal: todos los pagarés (administración, de todas las casas; el broker, de las suyas), como «Pagos» del panel:
/// agrupados por casa y cliente, con lo que se puede hacer en cada uno (registrar, corregir o anular el pago,
/// editar o cancelar el pagaré, PDF y fotos de sellos), según los permisos.
class StaffPaymentsPage extends ConsumerStatefulWidget {
  const StaffPaymentsPage({super.key});

  @override
  ConsumerState<StaffPaymentsPage> createState() => _StaffPaymentsPageState();
}

class _StaffPaymentsPageState extends ConsumerState<StaffPaymentsPage> {
  static const _tabs = ['Por cobrar', 'Vencidos', 'Pagados', 'Todos'];
  int _tab = 0;

  bool _fits(PromissoryNote n) => switch (_tab) {
        0 => n.status == 'pending' || n.status == 'overdue',
        1 => n.status == 'overdue',
        2 => n.status == 'paid',
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(allNotesProvider);
    final admin = ref.watch(sessionProvider.select((s) => s.value?.isAdmin ?? false));
    return Scaffold(
      appBar: AppBar(title: const Text('Pagos y pagarés')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedTabs(tabs: _tabs, selected: _tab, onChanged: (i) => setState(() => _tab = i)),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: switch (notes) {
              AsyncData(:final value) => () {
                  final items = value.where(_fits).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.task_alt_rounded,
                      title: _tab == 1 ? 'Sin pagarés vencidos' : 'Sin pagarés aquí',
                      message: admin ? 'Los pagarés salen al registrar un contrato con «Rentarle esta casa».' : 'Aquí salen los pagarés de tus casas.',
                    );
                  }
                  // Un bloque por casa y cliente, con su total
                  final groups = <String, List<PromissoryNote>>{};
                  for (final n in items) {
                    groups.putIfAbsent('${n.property?.name ?? 'Casa'} · ${n.client?.name ?? ''}', () => []).add(n);
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(allNotesProvider.future),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
                      children: [
                        Text('Toca un pagaré para registrar el pago o ver lo que puedes hacer.', style: AppTextStyles.secondary.copyWith(fontSize: 13)),
                        for (final g in groups.entries) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text(g.key, style: AppTextStyles.cardTitle),
                          Text(
                            '${g.value.length} ${g.value.length == 1 ? 'pagaré' : 'pagarés'} · ${Fmt.money(g.value.fold<double>(0, (s, n) => s + n.amount))}',
                            style: AppTextStyles.secondary.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          for (final n in g.value) ...[
                            NoteCard(
                              note: n,
                              title: '${n.label} - ${Fmt.dayMonthShort(n.dueDate)}',
                              subtitle: Fmt.money(n.amount),
                              onTap: () => showNoteActions(context, ref, n),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ],
                    ),
                  );
                }(),
              AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(allNotesProvider)),
              _ => const LoadingState(),
            },
          ),
        ],
      ),
    );
  }
}
