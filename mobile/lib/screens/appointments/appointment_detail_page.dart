import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/cards.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/states.dart';
import '../../widgets/property/property_widgets.dart';
import '../../services/repositories/requests_repository.dart';
import '../../widgets/requests/request_form_sections.dart';
import '../../models/appointment.dart';
import '../../services/providers/appointments_provider.dart';
import '../../widgets/appointments/appointment_card.dart';
import '../../widgets/appointments/appointment_chat.dart';
import '../../widgets/appointments/appointment_place_cards.dart';
import '../../widgets/appointments/my_data_card.dart';
import '../../widgets/appointments/staff_appointment_actions.dart';
import '../../widgets/common/visit_time.dart';

/// Cliente: la fecha de la visita la acuerdan ambos. Si el asesor propuso la fecha, «Aceptar» o «Proponer otra»;
/// si la propuso el cliente, espera a que el asesor la confirme (y también puede proponer otra).
class _DateAgreement extends ConsumerStatefulWidget {
  const _DateAgreement({required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<_DateAgreement> createState() => _DateAgreementState();
}

class _DateAgreementState extends ConsumerState<_DateAgreement> {
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

  Future<void> _propose() async {
    final now = Fmt.now();
    final day = await showDatePicker(
      context: context,
      initialDate: a.scheduledAt.isAfter(now) ? a.scheduledAt : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      helpText: 'Día que te queda mejor',
    );
    if (day == null || !mounted) return;
    final time = await pickVisitTime(context, initial: TimeOfDay.fromDateTime(a.scheduledAt));
    if (time == null || !mounted) return;
    final when = DateTime(day.year, day.month, day.day, time.hour, time.minute);
    final ok = await showConfirmDialog(
      context,
      title: 'Proponer otra fecha',
      message: 'Le proponemos a tu asesor el ${Fmt.appointment(when)}. Te avisamos cuando la confirme.',
      confirmLabel: 'Proponer',
    );
    if (!ok) return;
    await _run('propose', () => ref.read(appointmentActionsProvider).reschedule(a.id, when), 'Propusimos el ${Fmt.appointment(when)} a tu asesor.');
  }

  @override
  Widget build(BuildContext context) {
    final pending = a.status == 'por-confirmar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pending && a.canAccept) ...[
          InfoNotice(text: 'Tu asesor propone visitar ${a.property.name} el ${Fmt.appointment(a.scheduledAt)}. ¿Te queda bien?'),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Aceptar esta fecha',
            icon: Icons.check_rounded,
            loading: _busy == 'accept',
            onPressed: _busy != null
                ? null
                : () => _run('accept', () => ref.read(appointmentActionsProvider).confirm(a.id), 'Listo: tu visita es el ${Fmt.appointment(a.scheduledAt)}. Le avisamos a tu asesor.'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ] else if (pending)
          InfoNotice(text: 'Propusiste el ${Fmt.appointment(a.scheduledAt)}. Te avisamos en cuanto tu asesor la confirme.'),
        if (pending && !a.canAccept) const SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          label: pending && a.canAccept ? 'Proponer otra fecha' : 'Cambiar fecha u hora',
          icon: Icons.edit_calendar_outlined,
          variant: ButtonVariant.outline,
          loading: _busy == 'propose',
          onPressed: _busy != null ? null : _propose,
        ),
      ],
    );
  }
}

/// Pantalla 6 · Detalle de cita («Cita - Casa Las Palmas»).
class AppointmentDetailPage extends ConsumerWidget {
  const AppointmentDetailPage({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointment = ref.watch(appointmentProvider(appointmentId));
    return Scaffold(
      appBar: AppBar(),
      body: switch (appointment) {
        AsyncData(:final value) => _Detail(appointment: value),
        AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(appointmentProvider(appointmentId))),
        _ => const LoadingState(items: 3, itemHeight: 120),
      },
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.appointment});

  final Appointment appointment;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _chatOpen = true;
  bool _cancelling = false;

  Future<void> _cancel() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancelar cita',
      message: '¿Quieres cancelar tu visita a ${widget.appointment.property.name}? Avisaremos a la inmobiliaria.',
      confirmLabel: 'Cancelar cita',
      cancelLabel: 'Conservar',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _cancelling = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(appointmentActionsProvider).cancel(widget.appointment.id);
      messenger.showSnackBar(const SnackBar(content: Text('Tu cita se canceló.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final staff = a.client != null;
    final messages = ref.watch(appointmentMessagesProvider(a.id));
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(appointmentMessagesProvider(a.id));
        ref.invalidate(appointmentProvider(a.id));
        await ref.read(appointmentProvider(a.id).future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xxl),
        children: [
          Semantics(header: true, child: Text('Cita - ${a.property.name}', style: AppTextStyles.pageTitle.copyWith(fontSize: 24))),
          const SizedBox(height: AppSpacing.md),
          PropertyHero(
            height: 190,
            semanticLabel: 'Foto de ${a.property.name}',
            overlay: a.property.zone == null ? null : LocationChip(label: a.property.zone!),
          ),
          const SizedBox(height: AppSpacing.md),
          AppointmentCard(appointment: a),
          // Acuerdo de la fecha: la que propuso el asesor la acepta el cliente (o propone otra)
          if (!staff && a.isActive) ...[const SizedBox(height: AppSpacing.md), _DateAgreement(appointment: a)],
          // Personal: confirmar, rechazar o reprogramar arriba, a la vista (no hasta abajo, después del formulario y el chat)
          if (staff) ...[const SizedBox(height: AppSpacing.md), StaffAppointmentActions(appointment: a)],
          if (a.reason != null && (a.status == 'cancelada' || a.status == 'rechazada')) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Motivo: ${a.reason}', style: AppTextStyles.secondary.copyWith(fontSize: 13)),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text('Ubicación', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          AppointmentLocationCard(appointment: a),
          const SizedBox(height: AppSpacing.xl),
          // La API solo envía el cliente al personal: así se distingue la vista.
          if (staff) ...[
            Text(a.client?.kind == 'inquilino' ? 'Inquilino' : 'Prospecto', style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.sm),
            AppointmentClientCard(appointment: a),
          ] else if (a.broker != null) ...[
            // Contacto mutuo: el cliente ve a su asesor
            Text('Tu asesor', style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.sm),
            AppointmentAdvisorCard(appointment: a),
            const SizedBox(height: AppSpacing.xl),
          ],
          // El formulario que llenó (el personal lo ve completo; la persona, lo que ella escribió)
          if (a.lead case final lead?) ...[
            if (staff) const SizedBox(height: AppSpacing.xl),
            Text(staff ? (lead['linked'] == true ? 'Formulario que llenó' : 'Su solicitud más reciente') : 'Lo que nos contaste', style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.sm),
            RequestFormSections(request: LeadRequest.fromJson(lead), staff: staff),
            // La persona corrige aquí mismo lo que nos contó
            if (!staff && lead['status'] != 'cerrado') ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => context.push('/home/requests/new', extra: LeadRequest.fromJson(lead)),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Cambiar mi información'),
              ),
            ],
          ] else if (!staff) ...[
            Text('Mis Datos', style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.sm),
            const MyDataCard(),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: Text('Mensajes de la cita', style: AppTextStyles.sectionTitle)),
              if (!_chatOpen) TextButton(onPressed: () => setState(() => _chatOpen = true), child: const Text('Mostrar')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_chatOpen)
            switch (messages) {
              AsyncData(:final value) => AppointmentChat(
                messages: value,
                enabled: a.acceptsMessages,
                onClose: () => setState(() => _chatOpen = false),
                onSend: (body) async {
                  try {
                    await ref.read(appointmentMessagesProvider(a.id).notifier).send(body);
                    return null;
                  } catch (e) {
                    return ApiException.from(e).message;
                  }
                },
              ),
              AsyncError(:final error) => SizedBox(
                height: 220,
                child: ErrorState(error: error, onRetry: () => ref.invalidate(appointmentMessagesProvider(a.id))),
              ),
              _ => const SizedBox(height: 160, child: LoadingState(items: 2, itemHeight: 48)),
            },
          if (!staff && a.isActive) ...[const SizedBox(height: AppSpacing.xl), PrimaryButton(label: 'Cancelar cita', variant: ButtonVariant.danger, loading: _cancelling, onPressed: _cancel)],
        ],
      ),
    );
  }
}
