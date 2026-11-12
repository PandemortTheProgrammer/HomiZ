import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/theme/app_spacing.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/states.dart';
import '../../services/providers/payments_provider.dart';
import '../../widgets/payments/payments_tab.dart';

/// Pagarés vencidos de las casas del personal, con «Registrar pago» si tiene el permiso.
class OverdueNotesPage extends ConsumerWidget {
  const OverdueNotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(overdueNotesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pagarés vencidos')),
      body: switch (notes) {
        AsyncData(:final value) when value.isEmpty => const EmptyState(
            icon: Icons.task_alt_rounded,
            title: 'Sin pagarés vencidos',
            message: 'Todos los pagos de tus casas están al día.',
          ),
        AsyncData(:final value) => RefreshIndicator(
            onRefresh: () => ref.refresh(overdueNotesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: value.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final n = value[i];
                return NoteCard(
                  note: n,
                  title: '${n.label} - ${Fmt.dayMonthShort(n.dueDate)}',
                  subtitle: [n.client?.name, n.property?.name].whereType<String>().join(' · '),
                  onTap: n.property == null ? null : () => context.push('/property/${n.property!.id}?tab=2'),
                );
              },
            ),
          ),
        AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(overdueNotesProvider)),
        _ => const LoadingState(),
      },
    );
  }
}
