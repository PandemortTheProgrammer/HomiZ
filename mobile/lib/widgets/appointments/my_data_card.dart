import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/cards.dart';
import '../common/primary_button.dart';
import '../../models/app_user.dart';
import '../../services/repositories/auth_repository.dart';
import '../../services/providers/session_provider.dart';

/// «Mis Datos»: Nombre, Presupuesto, Mascotas e Inquilinos del expediente, con «Editar mis datos».
class MyDataCard extends ConsumerWidget {
  const MyDataCard({super.key});

  static String budgetText(ClientProfile? c) {
    if (c?.budgetAmount != null) return '${Fmt.money(c!.budgetAmount!)}/mes';
    return c?.budget ?? 'Sin registrar';
  }

  /// «Sí, 2» o solo «Sí» si no dijo cuántas (antes salía «Sí, 0»).
  static String petsText(ClientProfile? c) => (c?.hasPets ?? false) ? (c!.petsCount > 0 ? 'Sí, ${c.petsCount}' : 'Sí') : 'No';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    if (user == null) return const SizedBox.shrink();
    final c = user.client;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.cardAll,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              KeyValueRow(label: 'Nombre', value: user.name),
              KeyValueRow(label: 'Presupuesto', value: budgetText(c)),
              KeyValueRow(label: 'Mascotas', value: petsText(c)),
              KeyValueRow(label: 'Inquilinos', value: c?.occupants?.toString() ?? 'Sin registrar', showDivider: false),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: 'Editar mis datos',
          onPressed: c == null
              ? null
              : () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (context) => Padding(
                    padding: EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl),
                    child: _EditMyDataSheet(profile: c),
                  ),
                ),
        ),
      ],
    );
  }
}

class _EditMyDataSheet extends ConsumerStatefulWidget {
  const _EditMyDataSheet({required this.profile});

  final ClientProfile profile;

  @override
  ConsumerState<_EditMyDataSheet> createState() => _EditMyDataSheetState();
}

class _EditMyDataSheetState extends ConsumerState<_EditMyDataSheet> {
  final _form = GlobalKey<FormState>();
  late final _budget = TextEditingController(text: widget.profile.budgetAmount?.round().toString() ?? '');
  late final _occupants = TextEditingController(text: widget.profile.occupants?.toString() ?? '');
  late bool _hasPets = widget.profile.hasPets;
  late int _pets = widget.profile.petsCount < 1 ? 1 : widget.profile.petsCount;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _budget.dispose();
    _occupants.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(authRepositoryProvider)
          .updateProfile(
            client: {
              'budgetAmount': _budget.text.isEmpty ? null : double.parse(_budget.text),
              'hasPets': _hasPets,
              'petsCount': _hasPets ? _pets : 0,
              'occupants': _occupants.text.isEmpty ? null : int.parse(_occupants.text),
            },
          );
      ref.read(sessionProvider.notifier).updateUser(updated);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Editar mis datos', style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _budget,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
            decoration: const InputDecoration(labelText: 'Presupuesto mensual', prefixText: r'$ ', suffixText: 'MXN / mes'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _occupants,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
            decoration: const InputDecoration(labelText: 'Inquilinos (personas que vivirán en la casa)'),
            validator: (v) => (v != null && v.isNotEmpty && int.parse(v) < 1) ? 'Indica al menos 1 inquilino.' : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Tengo mascotas', style: AppTextStyles.body),
            value: _hasPets,
            onChanged: (v) => setState(() => _hasPets = v),
          ),
          if (_hasPets)
            Row(
              children: [
                Expanded(child: Text('¿Cuántas?', style: AppTextStyles.body)),
                IconButton(tooltip: 'Una mascota menos', onPressed: _pets > 1 ? () => setState(() => _pets--) : null, icon: const Icon(Icons.remove_circle_outline)),
                Text('$_pets', style: AppTextStyles.cardTitle),
                IconButton(tooltip: 'Una mascota más', onPressed: _pets < 20 ? () => setState(() => _pets++) : null, icon: const Icon(Icons.add_circle_outline)),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(_error!, style: AppTextStyles.secondary.copyWith(color: AppColors.danger, fontSize: 13)),
            ),
          PrimaryButton(label: 'Guardar', loading: _loading, onPressed: _save),
        ],
      ),
    );
  }
}
