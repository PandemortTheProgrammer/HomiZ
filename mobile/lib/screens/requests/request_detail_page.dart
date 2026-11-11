import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/cards.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/states.dart';
import '../../widgets/common/status_badge.dart';
import '../../services/providers/appointments_provider.dart';
import '../../services/providers/session_provider.dart';
import '../../services/providers/property_provider.dart';
import '../../services/repositories/requests_repository.dart';
import 'requests_page.dart';
import '../../widgets/requests/request_form_sections.dart';
import '../../services/providers/requests_provider.dart';
import '../../widgets/requests/schedule_request_sheet.dart';

/// Detalle de una solicitud: lo que pidió, la respuesta del asesor y las casas propuestas.
/// El personal además contesta, propone casas del inventario y cambia el seguimiento.
class RequestDetailPage extends ConsumerWidget {
  const RequestDetailPage({super.key, required this.requestId});

  final String requestId;

  /// Cita que pidió la persona y espera que el personal la acepte.
  static RequestAppointment? _askedVisit(LeadRequest r) =>
      r.appointments.where((a) => a.status == 'por-confirmar' && a.awaiting == 'staff' && a.scheduledAt.isAfter(Fmt.now())).firstOrNull;

  /// Fecha y hora que pidió en su solicitud, si aún no hay cita y la casa sigue disponible.
  static DateTime? _askedDate(LeadRequest r) {
    final day = r.preferredDate, time = r.preferredTime;
    if (r.propertyId == null || day == null || time == null || time.length < 5 || r.appointments.any((a) => a.isActive)) return null;
    final at = DateTime.tryParse('${day.substring(0, 10)}T${time.substring(0, 5)}:00');
    if (at == null || !at.isAfter(Fmt.now())) return null;
    final minutes = at.hour * 60 + at.minute;
    return minutes >= 7 * 60 && minutes <= 22 * 60 + 45 ? at : null; // horario de visitas
  }

  /// Con la prioridad de otro broker se puede leer, pero no atender. La dueña siempre puede.
  static bool _readOnly(LeadRequest r, {required bool owner, required String? me}) => r.priorityBrokerId != null && r.priorityBrokerId != me && !owner;

  Future<void> _run(BuildContext context, Future<void> Function() action, String done) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(sessionProvider.select((s) => s.value?.isStaff ?? false));
    final admin = ref.watch(sessionProvider.select((s) => s.value?.isAdmin ?? false));
    final broker = ref.watch(sessionProvider.select((s) => s.value?.isBroker ?? false));
    final owner = ref.watch(sessionProvider.select((s) => s.value?.isOwner ?? false));
    final me = ref.watch(sessionProvider.select((s) => s.value?.id));
    final request = ref.watch(requestProvider(requestId));
    final actions = ref.read(requestActionsProvider);
    final locked = request.value != null && _readOnly(request.value!, owner: owner, me: me);
    return Scaffold(
      appBar: AppBar(
        title: Text(request.value == null ? 'Solicitud' : 'Solicitud ${request.value!.folio}'),
        actions: [
          if (staff && admin && request.value != null && !locked)
            IconButton(
              tooltip: 'Eliminar solicitud',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                final r = request.value!;
                final ok = await showConfirmDialog(context,
                    title: '¿Eliminar la solicitud ${r.folio}?', message: 'Se borran la solicitud, sus casas propuestas y la conversación. Las citas que se agendaron se conservan.', confirmLabel: 'Eliminar', destructive: true);
                if (!ok || !context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                final router = GoRouter.of(context);
                try {
                  await actions.remove(r.id);
                  messenger.showSnackBar(SnackBar(content: Text('Solicitud ${r.folio} eliminada.')));
                  router.pop();
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
                }
              },
            ),
        ],
      ),
      body: switch (request) {
        AsyncData(:final value) => RefreshIndicator(
            onRefresh: () => ref.refresh(requestProvider(requestId).future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.screen, AppSpacing.xxl),
              children: [
                ListCard(
                  title: staff ? '${value.name ?? ''} · ${value.reasonLabel}' : value.reasonLabel,
                  subtitle: ['Enviada el ${Fmt.dayMonthShort(value.createdAt)}', if (value.propertyName != null) value.propertyName!, if (staff && value.email != null) value.email!, if (staff && value.phone != null) value.phone!].join('\n'),
                  trailing: requestBadge(value),
                ),
                if (staff) ...[
                  const SizedBox(height: AppSpacing.md),
                  if (value.priorityLabel case final label?) ...[
                    InfoNotice(text: locked ? '${label.endsWith('.') ? label : '$label.'} Puedes verla, pero aún no atenderla.' : label),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _BrokerCard(request: value, admin: admin, broker: broker, readOnly: locked, onTake: () => _run(context, () => actions.take(value.id), 'Tomaste esta solicitud. Ahora su seguimiento es tuyo.'), onAssign: (id, name) => _run(context, () => actions.assign(value.id, id), 'Solicitud asignada a $name. Le avisamos y su cita se va con $name.')),
                ],
                const SizedBox(height: AppSpacing.md),
                RequestFormSections(request: value, staff: staff),
                // El cliente corrige lo que mandó mientras la solicitud siga abierta
                if (!staff && value.status != 'cerrado') ...[
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/home/requests/new', extra: value),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar mi información'),
                  ),
                ],
                if (staff && value.others.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Otras solicitudes de esta persona · ${value.others.length}', style: AppTextStyles.cardTitle),
                  const SizedBox(height: AppSpacing.sm),
                  for (final o in value.others) ...[
                    ListCard(
                      title: '${o.folio} · ${o.reasonLabel}',
                      subtitle: [Fmt.dayMonthShort(o.createdAt), o.propertyName ?? o.summary, if (o.message != null) '«${o.message!.length > 80 ? '${o.message!.substring(0, 80)}…' : o.message!}»'].where((s) => s.isNotEmpty).join(' · '),
                      trailing: requestBadge(o),
                      // Se abre en la misma pestaña (Solicitudes o Inicio)
                      onTap: () => context.push(GoRouterState.of(context).matchedLocation.replaceFirst(RegExp(r'[^/]+$'), o.id)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
                if (staff) ...[
                  // Lo principal: pasar la solicitud a una cita
                  const SizedBox(height: AppSpacing.lg),
                  Text('Citas', style: AppTextStyles.cardTitle),
                  const SizedBox(height: AppSpacing.sm),
                  if (value.appointments.isEmpty) Text('Aún no tiene cita. Agéndala y le avisamos en la app.', style: AppTextStyles.secondary),
                  for (final a in value.appointments) ...[
                    ListCard(
                      title: '${a.code} · ${a.propertyName}',
                      subtitle: [Fmt.appointment(a.scheduledAt), if (a.broker != null) a.broker!].join('\n'),
                      trailing: StatusBadge.fromStatus(a.status),
                      onTap: () => context.push('/appointments/${a.id}'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (locked)
                    const SizedBox.shrink()
                  else if (_askedVisit(value) case final a?) ...[
                    Text('Pidió ${Fmt.appointment(a.scheduledAt)}. Si estás de acuerdo con la fecha y la hora, haz la cita.', style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.sm),
                    PrimaryButton(
                      label: 'Hacer cita',
                      icon: Icons.check_rounded,
                      onPressed: () => _run(context, () async {
                        await ref.read(appointmentActionsProvider).confirm(a.id);
                        ref.invalidate(requestProvider(requestId));
                      }, 'Cita ${a.code} confirmada. Le avisamos al cliente.'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ] else if (_askedDate(value) case final at?) ...[
                    Text('Pidió ${Fmt.appointment(at)}. Si estás de acuerdo con la fecha y la hora, haz la cita.', style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.sm),
                    PrimaryButton(
                      label: 'Hacer cita',
                      icon: Icons.check_rounded,
                      onPressed: () => _run(context, () => actions.schedule(value.id, propertyId: value.propertyId!, at: at, agreed: true), 'Cita confirmada. Le avisamos al cliente.'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (!locked) PrimaryButton(
                    label: value.appointments.any((a) => a.isActive) ? 'Cambiar fecha de la cita' : 'Agendar cita',
                    icon: Icons.event_available_outlined,
                    onPressed: () async {
                      final code = await showScheduleRequestSheet(context, value);
                      if (code != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cita $code guardada. Quedó por confirmar y le avisamos al cliente.')));
                      }
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(staff ? 'Conversación con el cliente' : 'Mensajes con tu asesor', style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.sm),
                if (value.response != null) ...[
                  InfoNotice(text: '${value.response!}${value.respondedBy != null ? '\n— ${value.respondedBy}' : ''}'),
                  const SizedBox(height: AppSpacing.sm),
                ],
                RequestChat(requestId: value.id, staff: staff, readOnly: locked),
                const SizedBox(height: AppSpacing.lg),
                Text(staff ? 'Casas propuestas' : 'Casas que te proponemos', style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.sm),
                if (value.proposals.isEmpty)
                  Text(staff ? 'Aún no le propones casas.' : 'Aún no hay casas propuestas. Si no tenemos una así, te la conseguimos.', style: AppTextStyles.secondary),
                for (final p in value.proposals) ...[
                  ListCard(
                    title: p.name,
                    caption: '${Fmt.money(p.price)}${p.operation == 'renta' ? ' / mes' : ''}',
                    subtitle: ['${p.zone}${p.city != null ? ', ${p.city!.split(',').first}' : ''}', '${p.rec} rec. · ${p.banos % 1 == 0 ? p.banos.toInt() : p.banos} baños', if (p.note != null) '«${p.note}»'].join('\n'),
                    trailing: locked
                        ? null
                        : staff
                        ? IconButton(
                            tooltip: 'Quitar ${p.name}',
                            icon: const Icon(Icons.close_rounded, color: AppColors.danger),
                            onPressed: () async {
                              final ok = await showConfirmDialog(context, title: '¿Quitar ${p.name}?', message: 'El cliente dejará de verla en sus propuestas.', confirmLabel: 'Quitar', destructive: true);
                              if (ok && context.mounted) await _run(context, () => actions.unpropose(value.id, p.id), '${p.name} se quitó de las propuestas.');
                            },
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    // El cliente agenda la visita de la casa propuesta
                    onTap: staff ? null : () => context.push('/appointments/catalog/${p.propertyId}'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (locked)
                  const SizedBox.shrink()
                else if (staff) ...[
                  PrimaryButton(
                    label: 'Proponer una casa',
                    icon: Icons.add_home_outlined,
                    variant: ButtonVariant.outline,
                    onPressed: () => _pickHouse(context, ref, value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Seguimiento', style: AppTextStyles.cardTitle),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<String>(
                    segments: const [ButtonSegment(value: 'nuevo', label: Text('Nueva')), ButtonSegment(value: 'en_seguimiento', label: Text('Seguimiento')), ButtonSegment(value: 'cerrado', label: Text('Cerrada'))],
                    selected: {value.status},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => _run(context, () => actions.setStatus(value.id, s.first), 'Seguimiento actualizado.'),
                  ),
                ] else ...[
                  if (value.proposals.isNotEmpty) ...[
                    // Menú desplegable: el cliente elige cuál quiere visitar (una cita a la vez)
                    const SizedBox(height: AppSpacing.sm),
                    _ChooseProposal(proposals: value.proposals),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  // Todas las propiedades activas, en tarjetas
                  PrimaryButton(
                    label: 'Te mostramos más opciones',
                    icon: Icons.apartment_outlined,
                    variant: ButtonVariant.outline,
                    onPressed: () => context.push('/appointments/catalog'),
                  ),
                ],
              ],
            ),
          ),
        AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(requestProvider(requestId))),
        _ => const LoadingState(),
      },
    );
  }

  /// Personal: elige una casa publicada del inventario y una nota opcional.
  Future<void> _pickHouse(BuildContext context, WidgetRef ref, LeadRequest r) async {
    final taken = r.proposals.map((p) => p.propertyId).toSet();
    final houses = (await ref.read(allHousesProvider.future))
        .where((h) => h.visibility == 'publicada' && (h.status == 'disponible' || h.status == 'reservada') && !taken.contains(h.id))
        .toList();
    if (!context.mounted) return;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.sm), child: Text('Proponer una casa', style: AppTextStyles.pageTitle, textAlign: TextAlign.center)),
              if (houses.isEmpty) const Padding(padding: EdgeInsets.all(AppSpacing.screen), child: Text('No hay casas publicadas disponibles para proponer.', textAlign: TextAlign.center)),
              for (final h in houses)
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: Text(h.name),
                  subtitle: Text('${h.zone ?? ''} · ${h.operation == 'venta' ? 'Venta' : 'Renta'} ${Fmt.money(h.price)}'),
                  onTap: () => Navigator.pop(context, h.id),
                ),
            ],
          ),
        ),
      ),
    );
    if (chosen == null || !context.mounted) return;
    final note = await _askText(context, title: 'Nota para el cliente (opcional)', label: 'Por qué se la propones', optional: true);
    if (!context.mounted) return;
    await _run(context, () => ref.read(requestActionsProvider).propose(r.id, chosen, note: note), 'Casa propuesta. Le avisamos al cliente.');
  }
}

/// Conversación de la solicitud: el cliente y su asesor se escriben aquí (en lugar del correo).
class RequestChat extends ConsumerStatefulWidget {
  const RequestChat({super.key, required this.requestId, required this.staff, this.readOnly = false});

  final String requestId;
  final bool staff;

  /// Se leen los mensajes, pero no se escribe.
  final bool readOnly;

  @override
  ConsumerState<RequestChat> createState() => _RequestChatState();
}

class _RequestChatState extends ConsumerState<RequestChat> {
  final _text = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(requestActionsProvider).sendMessage(widget.requestId, body);
      _text.clear();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(requestMessagesProvider(widget.requestId));
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.cardAll, border: Border.all(color: AppColors.divider)),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...switch (messages) {
            AsyncData(:final value) when value.isEmpty => [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    widget.staff ? 'Aún no hay mensajes. Escríbele para darle seguimiento.' : 'Aún no hay mensajes. Escríbele a tu asesor; te avisaremos cuando conteste.',
                    style: AppTextStyles.secondary,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            AsyncData(:final value) => [
                for (final m in value)
                  Align(
                    alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(color: m.mine ? AppColors.success : AppColors.chipInactive, borderRadius: AppRadius.cardAll),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${m.sender} · ${Fmt.dayMonthShort(m.createdAt)} ${Fmt.time(m.createdAt)}',
                              style: AppTextStyles.small.copyWith(color: m.mine ? Colors.white70 : AppColors.textMuted, fontWeight: FontWeight.w400)),
                          Text(m.body, style: AppTextStyles.body.copyWith(color: m.mine ? Colors.white : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
              ],
            AsyncError() => [Text('No se pudieron cargar los mensajes.', style: AppTextStyles.secondary)],
            _ => [const Padding(padding: EdgeInsets.all(AppSpacing.md), child: Center(child: CircularProgressIndicator()))],
          },
          if (!widget.readOnly) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: widget.staff ? 'Escribe al cliente' : 'Escribe a tu asesor', counterText: ''),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                tooltip: 'Enviar mensaje',
                onPressed: _sending ? null : _send,
                style: IconButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
              ),
            ],
          ),
          ],
        ],
      ),
    );
  }
}

/// Ventana con un campo de texto (respuesta o nota). Devuelve null si se cancela.
Future<String?> _askText(BuildContext context, {required String title, required String label, String? initial, bool optional = false}) =>
    showDialog<String>(context: context, builder: (_) => _TextDialog(title: title, label: label, initial: initial, optional: optional));

/// El campo vive en el estado de la ventana: se libera cuando la ventana termina de cerrarse
/// (liberarlo al salir de showDialog fallaba durante la animación de cierre).
/// Broker que atiende la solicitud. Llega sin broker y administración lo asigna (o lo cambia);
/// los datos de la persona no cambian y su cita pasa al broker elegido.
class _BrokerCard extends ConsumerWidget {
  const _BrokerCard({required this.request, required this.admin, required this.broker, required this.readOnly, required this.onAssign, required this.onTake});

  final LeadRequest request;
  final bool admin;

  /// También es broker (puede ser administración y broker a la vez): puede tomar la solicitud.
  final bool broker;

  /// Otro broker tiene la prioridad: aquí no se toma ni se asigna.
  final bool readOnly;
  final void Function(String id, String name) onAssign;
  final VoidCallback onTake;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unassigned = request.brokerId == null;
    final assigns = admin && !readOnly;
    final brokers = assigns ? ref.watch(assignableBrokersProvider).value ?? const <({String id, String name})>[] : const <({String id, String name})>[];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: unassigned ? Theme.of(context).colorScheme.error : AppColors.divider, width: unassigned ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Broker asignado', style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.xs),
          if (unassigned && broker && !readOnly) ...[
            Text('Nadie la atiende todavía. El primero que la toma se queda con su seguimiento.', style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(label: 'Atender esta solicitud', icon: Icons.handshake_outlined, onPressed: onTake),
            if (assigns) const SizedBox(height: AppSpacing.md),
          ] else if (!assigns)
            Text(request.brokerName ?? 'Sin asignar', style: AppTextStyles.body),
          if (assigns) ...[
            DropdownButtonFormField<String>(
              key: ValueKey(request.brokerId),
              initialValue: brokers.any((b) => b.id == request.brokerId) ? request.brokerId : null,
              isExpanded: true,
              hint: Text(request.brokerName ?? 'Sin asignar · elige un broker'),
              items: [for (final b in brokers) DropdownMenuItem(value: b.id, child: Text(b.name, overflow: TextOverflow.ellipsis))],
              onChanged: (id) {
                final b = brokers.where((x) => x.id == id).firstOrNull;
                if (b != null && b.id != request.brokerId) onAssign(b.id, b.name);
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              unassigned ? 'Llegó sin broker. Elige quién la atiende: le avisamos y la cita (si pidió una) queda con él.' : 'Puedes cambiarlo: la cita vigente pasa al nuevo broker.',
              style: AppTextStyles.secondary.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _TextDialog extends StatefulWidget {
  const _TextDialog({required this.title, required this.label, this.initial, required this.optional});

  final String title;
  final String label;
  final String? initial;
  final bool optional;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _controller = TextEditingController(text: widget.initial ?? '');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _controller.text.trim();
    if (!widget.optional && t.length < 2) return setState(() => _error = 'Escribe la respuesta.');
    Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 2,
        maxLines: 6,
        maxLength: widget.optional ? 300 : 2000,
        decoration: InputDecoration(labelText: widget.label, errorText: _error),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, widget.optional ? '' : null), child: Text(widget.optional ? 'Sin nota' : 'Cancelar')),
        TextButton(onPressed: _submit, child: Text(widget.optional ? 'Proponer' : 'Enviar')),
      ],
    );
  }
}

/// Cliente: menú desplegable con las casas propuestas; elige una y va a agendar (o cambiar) su visita.
/// Tiene una cita a la vez: si ya tiene una, se cambia a la casa elegida.
class _ChooseProposal extends ConsumerStatefulWidget {
  const _ChooseProposal({required this.proposals});

  final List<ProposedHouse> proposals;

  @override
  ConsumerState<_ChooseProposal> createState() => _ChooseProposalState();
}

class _ChooseProposalState extends ConsumerState<_ChooseProposal> {
  String? _chosen;

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeAppointmentProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _chosen,
          isExpanded: true,
          decoration: const InputDecoration(labelText: '¿Cuál quieres visitar?'),
          items: [
            for (final p in widget.proposals)
              DropdownMenuItem(value: p.propertyId, child: Text('${p.name} · ${Fmt.money(p.price)}${p.operation == 'renta' ? ' / mes' : ''}', overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => setState(() => _chosen = v),
        ),
        if (active != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Ya tienes la cita ${active.code} en ${active.property.name}: al agendar, esa cita pasa a la casa que elijas.', style: AppTextStyles.secondary.copyWith(fontSize: 13)),
        ],
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: active == null ? 'Agendar visita' : 'Cambiar mi cita a esta casa',
          icon: Icons.event_available_outlined,
          onPressed: _chosen == null ? null : () => context.push('/appointments/catalog/$_chosen'),
        ),
      ],
    );
  }
}
