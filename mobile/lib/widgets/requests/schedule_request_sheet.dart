import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/network/api_exception.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/primary_button.dart';
import '../../services/providers/property_provider.dart';
import '../../services/repositories/requests_repository.dart';
import '../../services/providers/requests_provider.dart';
import '../common/visit_time.dart';

/// Abre la hoja «Agendar cita» y devuelve la clave de la cita creada (o null si se cierra).
Future<String?> showScheduleRequestSheet(BuildContext context, LeadRequest request) => showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl),
        child: SingleChildScrollView(child: ScheduleRequestSheet(request: request)),
      ),
    );

/// Personal: agenda la visita de la persona de la solicitud. Casa (primero la que pidió y las propuestas),
/// día y horario. La cita queda «por confirmar» en Citas y a la persona le llega el aviso.
class ScheduleRequestSheet extends ConsumerStatefulWidget {
  const ScheduleRequestSheet({super.key, required this.request});

  final LeadRequest request;

  @override
  ConsumerState<ScheduleRequestSheet> createState() => _ScheduleRequestSheetState();
}

class _ScheduleRequestSheetState extends ConsumerState<ScheduleRequestSheet> {
  late final _note = TextEditingController(text: widget.request.message ?? '');
  String? _house;
  DateTime? _day;
  String? _time;
  String? _error;
  bool _saving = false;

  /// Casas que aceptan visitas: una rentada o vendida no se ofrece.
  Set<String> _free = const {};

  static bool _visitable(String? status) => status != 'borrador' && status != 'rentada' && status != 'vendida';

  LeadRequest get r => widget.request;

  /// Cita vigente de la solicitud: se reprograma esa misma (no se crea otra)
  RequestAppointment? get _active => r.appointments.where((a) => a.isActive).firstOrNull;

  /// La de la cita vigente, la que pidió y las propuestas, para marcarlas y ponerlas primero.
  Set<String> get _suggested => {
        ?_active?.propertyId,
        ?r.propertyId,
        ...r.proposals.map((p) => p.propertyId),
      };

  @override
  void initState() {
    super.initState();
    _house = _suggested.firstOrNull;
    // Si dio fecha y hora en el formulario y siguen vigentes, ya quedan elegidas
    final d = DateTime.tryParse(r.preferredDate ?? '');
    if (d != null && !d.isBefore(DateUtils.dateOnly(DateTime.now()))) _day = d;
    final t = r.preferredTime?.substring(0, 5);
    if (t != null && visitTimes.contains(t)) _time = t;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final p = _time?.split(':');
    final picked = await pickVisitTime(context, initial: p == null ? null : TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1])));
    if (picked != null) setState(() => _time = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
  }

  Future<void> _pickDay() async {
    final now = Fmt.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? now.add(const Duration(days: 1)),
      firstDate: DateUtils.dateOnly(now),
      lastDate: now.add(const Duration(days: 120)),
      helpText: 'Día de la visita',
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _save() async {
    if (_house == null || !_free.contains(_house) || _day == null || _time == null) {
      return setState(() => _error = 'Elige la casa, el día y el horario.');
    }
    final parts = _time!.split(':');
    final at = DateTime(_day!.year, _day!.month, _day!.day, int.parse(parts[0]), int.parse(parts[1]));
    if (!at.isAfter(Fmt.now())) return setState(() => _error = 'Elige un horario que no haya pasado.');
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final code = await ref.read(requestActionsProvider).schedule(r.id, propertyId: _house!, at: at, note: _note.text);
      if (mounted) Navigator.pop(context, code);
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(allHousesProvider);
    final suggested = _suggested;
    final all = inventory.value ?? const [];
    final houses = [...all.where((h) => _visitable(h.status))]
      ..sort((a, b) => (suggested.contains(b.id) ? 1 : 0) - (suggested.contains(a.id) ? 1 : 0));
    _free = houses.map((h) => h.id).toSet();
    // La casa de la solicitud ya se rentó o se vendió: hay que elegir otra
    final gone = r.propertyId != null && all.any((h) => h.id == r.propertyId && !_visitable(h.status));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_active == null ? 'Agendar cita' : 'Cambiar la cita', style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _active == null
              ? 'Para ${r.name ?? 'la persona'} · visita de 15 minutos. Queda por confirmar y le avisamos en la app.'
              : 'Ya tiene la cita ${_active!.code} (${_active!.propertyName}). Elige el nuevo día y horario: se mueve esa misma cita.',
          style: AppTextStyles.secondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (gone) ...[
          Text('${r.propertyName ?? 'La casa que pidió'} ya no está disponible. Elige otra casa para la visita.', style: AppTextStyles.secondary.copyWith(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
        ],
        if (inventory.isLoading && inventory.value == null)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<String>(
            initialValue: _free.contains(_house) ? _house : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Casa', helperText: '★ = la que pidió o las que le propusiste'),
            items: [
              for (final h in houses)
                DropdownMenuItem(value: h.id, child: Text('${suggested.contains(h.id) ? '★ ' : ''}${h.name} · ${h.operation == 'venta' ? 'Venta' : 'Renta'} ${Fmt.money(h.price)}', overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() => _house = v),
          ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _pickDay,
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(_day == null ? 'Elegir día' : Fmt.dayMonthShort(_day!)),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _pickTime,
          icon: const Icon(Icons.schedule_outlined),
          label: Text(_time == null ? 'Elegir hora' : Fmt.hhmm(_time!)),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(controller: _note, minLines: 1, maxLines: 3, maxLength: 500, decoration: const InputDecoration(labelText: 'Nota para la visita (opcional)')),
        if (_error != null) ...[
          Text(_error!, style: AppTextStyles.secondary.copyWith(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
        ],
        PrimaryButton(label: _active == null ? 'Agendar cita' : 'Cambiar fecha', icon: Icons.event_available_outlined, loading: _saving, onPressed: _saving ? null : _save),
      ],
    );
  }
}
