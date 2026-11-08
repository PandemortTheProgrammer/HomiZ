import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../../services/network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/cards.dart';
import '../common/confirm_dialog.dart';
import '../common/contact_actions.dart';
import '../common/permission_gate.dart';
import '../common/primary_button.dart';
import '../../services/repositories/documents_repository.dart';
import '../../services/repositories/payments_repository.dart';
import '../../models/appointment.dart';
import '../../services/providers/appointments_provider.dart';

/// Datos del cliente de la cita (solo personal) con Llamar / Correo.
class AppointmentClientCard extends StatelessWidget {
  const AppointmentClientCard({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final c = appointment.client!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (c.code != null) KeyValueRow(label: 'ID', value: c.code!),
          KeyValueRow(label: 'Nombre', value: c.name),
          KeyValueRow(label: 'Teléfono', value: c.phone ?? 'Sin registrar'),
          KeyValueRow(label: 'Correo', value: c.email ?? 'Sin registrar', showDivider: appointment.note != null || appointment.broker != null),
          if (appointment.broker != null) KeyValueRow(label: 'Asesor', value: appointment.broker!.name, showDivider: appointment.note != null),
          if (appointment.note != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text('Comentario: ${appointment.note}', style: AppTextStyles.body.copyWith(fontSize: 13)),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ContactActions(phone: c.phone, email: c.email, subject: 'Tu visita a ${appointment.property.name}'),
          ),
        ],
      ),
    );
  }
}

/// Pide un motivo. El controlador vive en el estado del diálogo para liberarse cuando el diálogo
/// termina de cerrarse (liberarlo al salir de showDialog fallaba durante la animación de cierre).
class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.title, required this.label, required this.confirm, required this.required});

  final String title;
  final String label;
  final String confirm;
  final bool required;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (widget.required && text.length < 3) {
      setState(() => _error = 'Escribe el motivo.');
      return;
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        maxLength: 300,
        decoration: InputDecoration(labelText: widget.label, errorText: _error),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
        TextButton(onPressed: _submit, child: Text(widget.confirm)),
      ],
    );
  }
}

/// Hacer inquilino (solo administración y propietario): periodo de renta, día de pago, renta y depósito.
/// Los pagarés mensuales se generan solos; se sube el contrato firmado en PDF.
class TenantSheet extends ConsumerStatefulWidget {
  const TenantSheet({super.key, required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<TenantSheet> createState() => _TenantSheetState();
}

class _TenantSheetState extends ConsumerState<TenantSheet> {
  final _form = GlobalKey<FormState>();
  final _rent = TextEditingController();
  final _deposit = TextEditingController();
  int _day = 5;
  late DateTime _start = DateUtils.dateOnly(DateTime.now());
  late DateTime _end = DateTime(_start.year + 1, _start.month, _start.day).subtract(const Duration(days: 1));
  bool _loading = false;
  String? _error;

  /// Contrato firmado (obligatorio)
  XFile? _contractPdf;
  String? _step;

  Future<XFile?> _pickPdf() async {
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf']);
    if (picked.isEmpty) return null;
    final file = picked.first.xFile;
    if (await file.length() > 50 * 1024 * 1024) {
      if (mounted) setState(() => _error = 'El PDF pesa más de 50 MB.');
      return null;
    }
    return file;
  }

  @override
  void dispose() {
    _rent.dispose();
    _deposit.dispose();
    super.dispose();
  }

  static double? _amount(String v) => double.tryParse(v.replaceAll(RegExp(r'[^\d.]'), ''));

  /// Cuántos pagarés salen: un pago al mes en el día de pago, del inicio al fin (igual que el servidor)
  int get _notesCount {
    var d = DateTime(_start.year, _start.month, _day);
    if (d.isBefore(_start)) d = DateTime(_start.year, _start.month + 1, _day);
    var n = 0;
    while (!d.isAfter(_end) && n < 600) {
      n++;
      d = DateTime(d.year, d.month + 1, _day);
    }
    return n;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (!_end.isAfter(_start)) return setState(() => _error = 'El fin del contrato debe ser después del inicio.');
    if (_contractPdf == null) return setState(() => _error = 'Sube el contrato firmado (PDF).');
    if (_notesCount == 0) return setState(() => _error = 'Con esas fechas no cae ningún día de pago.');
    setState(() {
      _loading = true;
      _error = null;
      _step = 'Creando el contrato y los pagarés…';
    });
    final a = widget.appointment;
    final docs = ref.read(documentsRepositoryProvider);
    String? contractId;
    try {
      contractId = await ref
          .read(paymentsRepositoryProvider)
          .createContract(propertyId: a.property.id, clientId: a.client!.id, start: _start, end: _end, monthlyRent: _amount(_rent.text)!, paymentDay: _day, deposit: _amount(_deposit.text));
      setState(() => _step = 'Subiendo el contrato firmado…');
      await docs.attachContractPdf(contractId, a.property.id, _contractPdf!);
      ref.invalidate(appointmentProvider(a.id));
      if (mounted) Navigator.pop(context, 'Se generaron $_notesCount pagarés mensuales y la casa salió del catálogo.');
    } catch (e) {
      final msg = ApiException.from(e).message;
      // Si el contrato ya se creó, el PDF se sube después desde la casa
      if (mounted) setState(() => _error = contractId != null ? 'El contrato y los pagarés se crearon, pero no se pudo subir el PDF: $msg' : msg);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _step = null;
        });
      }
    }
  }

  Future<void> _pick(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _start : _end,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: start ? 'Inicio del contrato' : 'Fin del contrato',
    );
    if (picked != null) setState(() => start ? _start = picked : _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Rentar ${a.property.name}', style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${a.client?.name ?? ''} pasa a inquilina: elige el periodo de renta y el día de pago; los pagarés mensuales se generan solos y la casa sale del catálogo.',
            style: AppTextStyles.secondary.copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: _loading ? null : () => _pick(true), child: Text('Inicio: ${Fmt.dayMonthShort(_start)} ${_start.year}')),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(onPressed: _loading ? null : () => _pick(false), child: Text('Fin: ${Fmt.dayMonthShort(_end)} ${_end.year}')),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _rent,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            decoration: const InputDecoration(labelText: 'Renta mensual (MXN)', prefixText: r'$ '),
            validator: (v) => (_amount(v ?? '') ?? 0) <= 0 ? 'Escribe la renta mensual.' : null,
          ),
          DropdownButtonFormField<int>(
            initialValue: _day,
            decoration: const InputDecoration(labelText: 'Día de pago de cada mes'),
            items: [for (var d = 1; d <= 28; d++) DropdownMenuItem(value: d, child: Text('Día $d'))],
            onChanged: _loading ? null : (v) => setState(() => _day = v ?? _day),
          ),
          TextFormField(
            controller: _deposit,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            decoration: const InputDecoration(labelText: 'Depósito (MXN, opcional)', prefixText: r'$ '),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: _loading
                ? null
                : () async {
                    final f = await _pickPdf();
                    if (f != null) setState(() => _contractPdf = f);
                  },
            icon: Icon(_contractPdf == null ? Icons.upload_file_outlined : Icons.check_circle_outline),
            label: Text(_contractPdf == null ? 'Contrato firmado (PDF) *' : 'Contrato: ${_contractPdf!.name}', overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _notesCount == 0
                ? 'Con esas fechas no cae ningún día de pago.'
                : 'Se generarán $_notesCount pagarés mensuales (día $_day de cada mes). Después podrás registrar cada pago y subir las fotos de sus sellos.',
            style: AppTextStyles.secondary.copyWith(fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(_error!, style: AppTextStyles.secondary.copyWith(color: AppColors.danger, fontSize: 13)),
            ),
          if (_step != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(_step!, style: AppTextStyles.secondary, textAlign: TextAlign.center),
            ),
          PrimaryButton(label: 'Crear contrato y pagarés', loading: _loading, onPressed: _save),
        ],
      ),
    );
  }
}

/// Confirmar · Rechazar · Reprogramar · Marcar como realizada · Cancelar (permiso appointments.manage).
class StaffAppointmentActions extends ConsumerStatefulWidget {
  const StaffAppointmentActions({super.key, required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<StaffAppointmentActions> createState() => _StaffAppointmentActionsState();
}

class _StaffAppointmentActionsState extends ConsumerState<StaffAppointmentActions> {
  String? _busy;

  Appointment get a => widget.appointment;

  Future<void> _run(String key, Future<void> Function() action, String done) async {
    setState(() => _busy = key);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<String?> _askReason({required String title, required String label, required String confirm, bool required = true}) => showDialog<String>(
    context: context,
    builder: (_) => _ReasonDialog(title: title, label: label, confirm: confirm, required: required),
  );

  Future<void> _reject() async {
    final reason = await _askReason(title: 'Rechazar cita', label: 'Motivo (lo verá el cliente)', confirm: 'Rechazar');
    if (reason == null) return;
    await _run('reject', () => ref.read(appointmentActionsProvider).reject(a.id, reason), 'Cita rechazada. Avisamos al cliente.');
  }

  Future<void> _reschedule() async {
    final now = Fmt.now();
    final day = await showDatePicker(
      context: context,
      initialDate: a.scheduledAt.isAfter(now) ? a.scheduledAt : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      helpText: 'Nuevo día de la visita',
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(initialEntryMode: TimePickerEntryMode.input, context: context, initialTime: TimeOfDay.fromDateTime(a.scheduledAt), helpText: 'Nueva hora');
    if (time == null || !mounted) return;
    final when = DateTime(day.year, day.month, day.day, time.hour, time.minute);
    final ok = await showConfirmDialog(
      context,
      title: 'Proponer nueva fecha',
      message: 'Le proponemos al cliente el ${Fmt.appointment(when)}. La cita queda por confirmar hasta que la acepte en su app (o proponga otra).',
      confirmLabel: 'Proponer fecha',
    );
    if (!ok) return;
    await _run('reschedule', () => ref.read(appointmentActionsProvider).reschedule(a.id, when), 'Nueva fecha propuesta. Avisamos al cliente para que la acepte.');
  }

  /// Confirmar: se muestran el día y la hora que se acuerdan antes de avisar al cliente.
  Future<void> _confirm() async {
    final ok = await showConfirmDialog(
      context,
      title: '¿Confirmar la visita?',
      message: '${Fmt.appointment(a.scheduledAt)} · ${a.property.name}${a.client != null ? ' con ${a.client!.name}' : ''}. Le avisamos al cliente con este día y hora.',
      confirmLabel: 'Confirmar',
    );
    if (!ok) return;
    await _run('confirm', () => ref.read(appointmentActionsProvider).confirm(a.id), 'Cita confirmada para el ${Fmt.appointment(a.scheduledAt)}. Avisamos al cliente.');
  }

  Future<void> _cancel() async {
    final reason = await _askReason(title: 'Cancelar cita', label: 'Motivo (opcional)', confirm: 'Cancelar cita', required: false);
    if (reason == null) return;
    await _run('cancel', () => ref.read(appointmentActionsProvider).cancel(a.id, reason: reason), 'Cita cancelada. Avisamos al cliente.');
  }

  /// Visita realizada: contrato de renta para que la persona quede como inquilina de la casa.
  Future<void> _rent() async {
    // Devuelve el aviso sobre los pagarés (null = se cerró sin crear el contrato)
    final saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl),
        child: SingleChildScrollView(child: TenantSheet(appointment: a)),
      ),
    );
    if (saved != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${a.client?.name ?? 'La persona'} ahora es inquilina de ${a.property.name}; se guardó el contrato firmado. $saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = a.scheduledAt.isAfter(Fmt.now());
    final pending = a.status == 'por-confirmar';
    final confirmed = a.status == 'confirmada';
    if (a.status == 'realizada' && a.client != null) {
      return PermissionGate(
        permission: 'contracts.manage',
        child: PrimaryButton(label: 'Rentarle esta casa (inquilino)', icon: Icons.key_outlined, onPressed: _rent),
      );
    }
    if (!pending && !confirmed) return const SizedBox.shrink();
    final disabled = _busy != null;
    return PermissionGate(
      permission: 'appointments.manage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (a.confirmedBy != null) ...[Text(a.confirmedBy!, style: AppTextStyles.secondary), const SizedBox(height: AppSpacing.md)],
          // La fecha la propuso el personal: la acepta el cliente en su app (acuerdo de ambos)
          if (pending && upcoming && a.awaiting == 'client') ...[
            InfoNotice(text: 'Esperando que ${a.client?.name.split(' ').first ?? 'el cliente'} acepte el ${Fmt.appointment(a.scheduledAt)}. Te avisamos cuando la acepte.'),
            const SizedBox(height: AppSpacing.md),
          ] else if (pending && upcoming) ...[
            PrimaryButton(label: 'Confirmar ${Fmt.appointment(a.scheduledAt)}', icon: Icons.check_rounded, loading: _busy == 'confirm', onPressed: disabled ? null : _confirm),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(label: 'Rechazar', variant: ButtonVariant.danger, loading: _busy == 'reject', onPressed: disabled ? null : _reject),
            const SizedBox(height: AppSpacing.md),
          ],
          if (confirmed) ...[
            PrimaryButton(
              label: 'Marcar como realizada',
              icon: Icons.task_alt_rounded,
              loading: _busy == 'complete',
              onPressed: disabled ? null : () => _run('complete', () => ref.read(appointmentActionsProvider).complete(a.id), 'Visita marcada como realizada.'),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          PrimaryButton(label: 'Reprogramar', icon: Icons.edit_calendar_outlined, variant: ButtonVariant.outline, loading: _busy == 'reschedule', onPressed: disabled ? null : _reschedule),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Cancelar cita', variant: ButtonVariant.danger, loading: _busy == 'cancel', onPressed: disabled ? null : _cancel),
        ],
      ),
    );
  }
}
