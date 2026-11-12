import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/primary_button.dart';
import '../../services/providers/session_provider.dart';
import '../../services/repositories/documents_repository.dart';
import '../documents/open_document.dart';
import '../../models/payment_models.dart';
import '../../services/providers/payments_provider.dart';
import 'register_payment_sheet.dart';

/// Acciones del personal sobre un pagaré, según su rol:
/// broker (payments.register / contracts.manage) registra pagos y edita pagarés pendientes;
/// administración (payments.correct) además corrige y anula pagos.
List<(IconData, String, Future<void> Function())> noteActions(BuildContext context, WidgetRef ref, PromissoryNote n) {
  final user = ref.read(sessionProvider).value;
  bool can(String p) => user?.can(p) ?? false;
  return [
    if (n.isPayable && can('payments.register')) (Icons.payments_outlined, 'Registrar pago', () => showRegisterPaymentSheet(context, n)),
    if (n.isPayable && can('contracts.manage')) ...[
      (Icons.edit_outlined, 'Editar pagaré', () => _sheet(context, EditNoteSheet(note: n), 'Pagaré actualizado.')),
      (Icons.delete_outline, 'Cancelar pagaré', () => _sheet(context, CancelNoteSheet(note: n), 'Pagaré cancelado; queda en el historial.')),
    ],
    if (n.payment != null && can('payments.correct')) ...[
      (Icons.build_outlined, 'Corregir pago', () => _sheet(context, CorrectPaymentSheet(note: n), 'Pago corregido. El cambio queda en el historial.')),
      (Icons.block_outlined, 'Anular pago', () => _sheet(context, VoidPaymentSheet(note: n), 'Pago anulado. El pagaré vuelve a estar por cobrar.')),
    ],
    if (n.documentId != null) (Icons.picture_as_pdf_outlined, 'Ver pagaré (PDF)', () => openDocument(context, ref, n.documentId!)),
    if (n.property != null && can('documents.manage'))
      (Icons.upload_file_outlined, n.documentId == null ? 'Subir pagaré (PDF)' : 'Reemplazar PDF del pagaré', () => _uploadNotePdf(context, ref, n)),
    if (n.proofDocumentId != null) (Icons.receipt_long_outlined, 'Ver recibo', () => openDocument(context, ref, n.proofDocumentId!)),
    // Sellos: fotos de la entrega del pagaré en físico y digital
    if (n.stamps.isNotEmpty) (Icons.photo_library_outlined, 'Ver sellos (${n.stamps.length})', () => showStamps(context, ref, n)),
    if (n.property != null && can('documents.manage')) (Icons.add_a_photo_outlined, 'Agregar foto del sello', () => _addStamps(context, ref, n)),
  ];
}

/// Elige una o varias fotos del sello y las sube ligadas al pagaré (el inquilino las ve en su app).
Future<void> _addStamps(BuildContext context, WidgetRef ref, PromissoryNote n) async {
  final messenger = ScaffoldMessenger.of(context);
  final photos = await ImagePicker().pickMultiImage(imageQuality: 85, maxWidth: 2400);
  if (photos.isEmpty) return;
  messenger.showSnackBar(SnackBar(content: Text('Subiendo ${photos.length == 1 ? 'la foto' : '${photos.length} fotos'} del sello…')));
  try {
    final docs = ref.read(documentsRepositoryProvider);
    for (final (i, p) in photos.indexed) {
      if (await p.length() > 10 * 1024 * 1024) throw const ApiException(code: 'FILE_TOO_LARGE', message: 'Una foto pesa más de 10 MB.');
      await docs.uploadStamp(n.property!.id, n.id, n.label, p, n.stamps.length + i + 1);
    }
    ref.invalidate(notesProvider);
    messenger.showSnackBar(SnackBar(content: Text('Se guardaron las fotos del sello del ${n.label}. El inquilino las ve en su app.')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
  }
}

/// Lista de las fotos de los sellos del pagaré; tocar una la abre.
Future<void> showStamps(BuildContext context, WidgetRef ref, PromissoryNote n) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xs),
              child: Text('Sellos del ${n.label}', style: AppTextStyles.pageTitle),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.sm),
              child: Text('Constancia de que se entregó el pagaré en físico y en digital.', style: AppTextStyles.secondary.copyWith(fontSize: 13)),
            ),
            for (final s in n.stamps)
              ListTile(
                leading: const Icon(Icons.photo_outlined, color: AppColors.primary),
                title: Text(s.name),
                subtitle: Text(Fmt.longDate(s.createdAt)),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => openDocument(context, ref, s.id),
              ),
          ],
        ),
      ),
    );

/// Elige el PDF firmado del pagaré y lo sube ligado a él (el cliente lo ve en su app).
Future<void> _uploadNotePdf(BuildContext context, WidgetRef ref, PromissoryNote n) async {
  final messenger = ScaffoldMessenger.of(context);
  final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf']);
  if (picked.isEmpty) return;
  final file = picked.first.xFile;
  if (await file.length() > 50 * 1024 * 1024) {
    messenger.showSnackBar(const SnackBar(content: Text('El PDF pesa más de 50 MB.')));
    return;
  }
  messenger.showSnackBar(SnackBar(content: Text('Subiendo el PDF del ${n.label}…')));
  try {
    await ref.read(documentsRepositoryProvider).uploadDocument(n.property!.id, file,
        type: 'promissory_note', name: '${n.label} firmado', visibleToClient: true, promissoryNoteId: n.id);
    ref.invalidate(notesProvider);
    messenger.showSnackBar(SnackBar(content: Text('Se guardó el PDF del ${n.label}. El cliente ya lo puede ver.')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
  }
}

const _danger = {'Anular pago', 'Cancelar pagaré'};

/// «Nuevo pagaré» del contrato vigente (contracts.manage). Devuelve true si se agregó.
Future<bool> showNewNoteSheet(BuildContext context, {required String contractId, required double rent}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl),
      child: SingleChildScrollView(child: NewNoteSheet(contractId: contractId, rent: rent)),
    ),
  );
  if ((saved ?? false) && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pagaré agregado. El cliente lo verá en su app.')));
  return saved ?? false;
}

/// Menú con las acciones permitidas del pagaré.
Future<void> showNoteActions(BuildContext context, WidgetRef ref, PromissoryNote n) async {
  final actions = noteActions(context, ref, n);
  if (actions.isEmpty) return;
  final chosen = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.sm),
            child: Text([n.label, Fmt.money(n.amount), if (n.client != null) n.client!.name].join(' · '), style: AppTextStyles.pageTitle),
          ),
          for (final (i, a) in actions.indexed)
            ListTile(
              leading: Icon(a.$1, color: _danger.contains(a.$2) ? AppColors.danger : AppColors.primary),
              title: Text(a.$2, style: _danger.contains(a.$2) ? const TextStyle(color: AppColors.danger) : null),
              onTap: () => Navigator.pop(context, i),
            ),
        ],
      ),
    ),
  );
  if (chosen != null && context.mounted) await actions[chosen].$3();
}

Future<void> _sheet(BuildContext context, Widget child, String doneMessage) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl),
      child: SingleChildScrollView(child: child),
    ),
  );
  if ((saved ?? false) && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(doneMessage)));
}

/// Estado común de los formularios: cargando, error y guardar.
mixin _SheetState<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final form = GlobalKey<FormState>();
  bool loading = false;
  String? error;

  Future<void> run(Future<void> Function() action) async {
    if (!form.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await action();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget header(String title, PromissoryNote n, [String? note]) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.xs),
          Text([n.label, if (n.client != null) n.client!.name, if (n.property != null) n.property!.name].join(' · '), style: AppTextStyles.secondary.copyWith(fontSize: 13)),
          if (note != null) ...[const SizedBox(height: AppSpacing.xs), Text(note, style: AppTextStyles.secondary.copyWith(fontSize: 13))],
          const SizedBox(height: AppSpacing.lg),
        ],
      );

  Widget footer(String label, {bool danger = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Semantics(liveRegion: true, child: Text(error!, style: AppTextStyles.secondary.copyWith(color: AppColors.danger, fontSize: 13))),
            ),
          PrimaryButton(label: label, loading: loading, onPressed: submit, variant: danger ? ButtonVariant.danger : ButtonVariant.primary),
        ],
      );

  void submit();
}

String? _money(String? v) {
  final n = double.tryParse((v ?? '').replaceAll(RegExp(r'[$,\s]'), ''));
  return n == null || n <= 0 ? 'Escribe un monto mayor a cero.' : null;
}

double _parse(String v) => double.parse(v.replaceAll(RegExp(r'[$,\s]'), ''));

/// Fecha elegida → hora del pago: hoy, la hora actual; otro día, mediodía (no cambia de fecha por la zona horaria).
DateTime _paidAt(DateTime day) {
  final now = DateTime.now();
  final same = day.year == now.year && day.month == now.month && day.day == now.day;
  return same ? now : DateTime(day.year, day.month, day.day, 12);
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

final _amountFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[\d.,$ ]'))];

/// «Editar pagaré»: monto y fecha de vencimiento (solo pendientes o vencidos).
class EditNoteSheet extends ConsumerStatefulWidget {
  const EditNoteSheet({super.key, required this.note});

  final PromissoryNote note;

  @override
  ConsumerState<EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends ConsumerState<EditNoteSheet> with _SheetState {
  late final _amount = TextEditingController(text: widget.note.amount.toStringAsFixed(0));
  late DateTime _due = widget.note.dueDate;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  void submit() => run(() async {
        final amount = _parse(_amount.text);
        final n = widget.note;
        if (amount == n.amount && _sameDay(_due, n.dueDate)) return;
        await ref.read(paymentActionsProvider).updateNote(n, amount: amount == n.amount ? null : amount, dueDate: _sameDay(_due, n.dueDate) ? null : _due);
      });

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header('Editar pagaré', widget.note, 'Solo se editan pagarés pendientes o vencidos.'),
          TextFormField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: _amountFormatters, decoration: const InputDecoration(labelText: 'Monto (MXN)', prefixText: r'$ '), validator: _money),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: loading
                ? null
                : () async {
                    final picked = await showDatePicker(context: context, initialDate: _due, firstDate: DateTime(_due.year - 1), lastDate: DateTime(_due.year + 3), helpText: 'Fecha de vencimiento');
                    if (picked != null) setState(() => _due = picked);
                  },
            icon: const Icon(Icons.event_outlined),
            label: Text('Vence el ${Fmt.longDate(_due)}'),
          ),
          footer('Guardar cambios'),
        ],
      ),
    );
  }
}

/// «Corregir pago»: monto, fecha, folio y notas de un pago registrado (solo administración).
class CorrectPaymentSheet extends ConsumerStatefulWidget {
  const CorrectPaymentSheet({super.key, required this.note});

  final PromissoryNote note;

  @override
  ConsumerState<CorrectPaymentSheet> createState() => _CorrectPaymentSheetState();
}

class _CorrectPaymentSheetState extends ConsumerState<CorrectPaymentSheet> with _SheetState {
  NotePayment get _p => widget.note.payment!;
  late final _amount = TextEditingController(text: _p.amount.toStringAsFixed(0));
  late final _folio = TextEditingController(text: _p.receiptFolio ?? '');
  late final _notes = TextEditingController(text: _p.notes ?? '');
  late DateTime _paidOn = _p.paidAt;

  @override
  void dispose() {
    _amount.dispose();
    _folio.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  void submit() => run(() async {
        final amount = _parse(_amount.text);
        final folio = _folio.text.trim();
        final notes = _notes.text.trim();
        final changed = amount != _p.amount || !_sameDay(_paidOn, _p.paidAt) || folio != (_p.receiptFolio ?? '') || (notes.isNotEmpty && notes != (_p.notes ?? ''));
        if (!changed) return;
        await ref.read(paymentActionsProvider).correct(
              widget.note,
              amount: amount == _p.amount ? null : amount,
              paidAt: _sameDay(_paidOn, _p.paidAt) ? null : _paidAt(_paidOn),
              receiptFolio: folio == (_p.receiptFolio ?? '') ? null : folio,
              notes: notes == (_p.notes ?? '') ? null : notes,
            );
      });

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header('Corregir pago', widget.note, 'Registrado por ${_p.registeredBy ?? 'el personal'}. La corrección queda en el historial.'),
          TextFormField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: _amountFormatters, decoration: const InputDecoration(labelText: 'Monto (MXN)', prefixText: r'$ '), validator: _money),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: loading
                ? null
                : () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(context: context, initialDate: _paidOn, firstDate: DateTime(now.year - 1), lastDate: now, helpText: 'Fecha del pago');
                    if (picked != null) setState(() => _paidOn = picked);
                  },
            icon: const Icon(Icons.event_outlined),
            label: Text('Pagado el ${Fmt.longDate(_paidOn)}'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _folio,
            maxLength: 40,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Folio del recibo'),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Escribe el folio del recibo.' : null,
          ),
          TextFormField(controller: _notes, maxLength: 500, maxLines: 2, decoration: const InputDecoration(labelText: 'Notas (opcional)')),
          footer('Guardar corrección'),
        ],
      ),
    );
  }
}

/// «Nuevo pagaré»: monto (número) y fecha de vencimiento.
class NewNoteSheet extends ConsumerStatefulWidget {
  const NewNoteSheet({super.key, required this.contractId, required this.rent});

  final String contractId;
  final double rent;

  @override
  ConsumerState<NewNoteSheet> createState() => _NewNoteSheetState();
}

class _NewNoteSheetState extends ConsumerState<NewNoteSheet> with _SheetState {
  late final _amount = TextEditingController(text: widget.rent.toStringAsFixed(0));
  DateTime _due = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  void submit() => run(() => ref.read(paymentActionsProvider).createNote(widget.contractId, amount: _parse(_amount.text), dueDate: _due));

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nuevo pagaré', style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.xs),
          Text('Un mes más o un cargo acordado del contrato vigente.', style: AppTextStyles.secondary.copyWith(fontSize: 13)),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: _amountFormatters, decoration: const InputDecoration(labelText: 'Monto (MXN)', prefixText: r'$ '), validator: _money),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: loading
                ? null
                : () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(context: context, initialDate: _due, firstDate: now, lastDate: DateTime(now.year + 3), helpText: 'Fecha de vencimiento');
                    if (picked != null) setState(() => _due = picked);
                  },
            icon: const Icon(Icons.event_outlined),
            label: Text('Vence el ${Fmt.longDate(_due)}'),
          ),
          footer('Agregar pagaré'),
        ],
      ),
    );
  }
}

/// «Cancelar pagaré»: ya no se cobrará; queda en el historial (sin pago registrado).
class CancelNoteSheet extends ConsumerStatefulWidget {
  const CancelNoteSheet({super.key, required this.note});

  final PromissoryNote note;

  @override
  ConsumerState<CancelNoteSheet> createState() => _CancelNoteSheetState();
}

class _CancelNoteSheetState extends ConsumerState<CancelNoteSheet> with _SheetState {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  void submit() => run(() => ref.read(paymentActionsProvider).cancelNote(widget.note, _reason.text));

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header('¿Cancelar este pagaré?', widget.note, '${Fmt.money(widget.note.amount)} · ya no se cobrará; queda en el historial.'),
          TextFormField(
            controller: _reason,
            maxLength: 300,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Motivo', hintText: 'Por ejemplo: se acordó no cobrar este cargo.'),
            validator: (v) => (v ?? '').trim().length < 5 ? 'Explica por qué se cancela (al menos 5 letras).' : null,
          ),
          footer('Sí, cancelar pagaré', danger: true),
        ],
      ),
    );
  }
}

/// «Anular pago»: pide el motivo; el pagaré vuelve a pendiente o vencido (solo administración).
class VoidPaymentSheet extends ConsumerStatefulWidget {
  const VoidPaymentSheet({super.key, required this.note});

  final PromissoryNote note;

  @override
  ConsumerState<VoidPaymentSheet> createState() => _VoidPaymentSheetState();
}

class _VoidPaymentSheetState extends ConsumerState<VoidPaymentSheet> with _SheetState {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  void submit() => run(() => ref.read(paymentActionsProvider).voidPayment(widget.note, _reason.text));

  @override
  Widget build(BuildContext context) {
    final p = widget.note.payment!;
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header('¿Anular este pago?', widget.note, '${Fmt.money(p.amount)} · folio ${p.receiptFolio ?? '—'}. El pago anulado queda en el historial.'),
          TextFormField(
            controller: _reason,
            maxLength: 300,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Motivo de la anulación', hintText: 'Por ejemplo: se registró en el pagaré equivocado.'),
            validator: (v) => (v ?? '').trim().length < 5 ? 'Explica por qué se anula el pago (al menos 5 letras).' : null,
          ),
          footer('Sí, anular pago', danger: true),
        ],
      ),
    );
  }
}
