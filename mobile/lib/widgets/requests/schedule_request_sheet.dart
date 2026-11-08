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

/// Horarios de visita (los mismos del panel).
/// Todo el día en bloques de 15 minutos (valor de 24 h, 00:00 a 23:45; se elige de 1 a 12 con a.m./p.m.): la visita dura 15 min
final visitTimes = [
  for (var m = 0; m < 24 * 60; m += 15) '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}',
];

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

  /// `_time` se guarda en 24 h («15:30», lo que manda la API); en pantalla se elige de 1 a 12 con a.m./p.m.
  int? get _hour12 {
    final h = int.tryParse(_time?.substring(0, 2) ?? '');
    return h == null ? null : (h % 12 == 0 ? 12 : h % 12);
  }

  bool get _pm => (int.tryParse(_time?.substring(0, 2) ?? '') ?? 9) >= 12;

  void _setTime({int? hour12, String? minutes, bool? pm}) {
    final h12 = hour12 ?? _hour12 ?? 9;
    final isPm = pm ?? _pm;
    final h = (h12 % 12) + (isPm ? 12 : 0);
    setState(() => _time = '${h.toString().padLeft(2, '0')}:${minutes ?? _time?.substring(3) ?? '00'}');
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
    if (_house == null || _day == null || _time == null) {
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
    final inventory = ref.watch(inventoryProvider(''));
    final suggested = _suggested;
    final houses = [...(inventory.value ?? const []).where((h) => h.status != 'borrador')]
      ..sort((a, b) => (suggested.contains(b.id) ? 1 : 0) - (suggested.contains(a.id) ? 1 : 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_active == null ? 'Agendar cita' : 'Cambiar la cita', style: AppTextStyles.pageTitle, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _active == null
              ? 'Para ${r.name ?? 'la persona'} · visita de 15 minutos. Queda por confirmar y le avisamos en la app.'
              : 'Ya tiene la cita ${_active!.code} (${_active!.propertyName}). Elige el nuevo día y horario: se mueve esa misma cita. Si eliges otra casa, se agenda una aparte.',
          style: AppTextStyles.secondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (inventory.isLoading && inventory.value == null)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<String>(
            initialValue: houses.any((h) => h.id == _house) ? _house : null,
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
        // Cualquier hora del día: hora de 1 a 12, minutos (:00, :15, :30, :45) y a.m./p.m.
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _hour12,
                decoration: const InputDecoration(labelText: 'Hora'),
                items: [for (var h = 1; h <= 12; h++) DropdownMenuItem(value: h, child: Text('$h'))],
                onChanged: (h) => _setTime(hour12: h),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _time?.substring(3),
                decoration: const InputDecoration(labelText: 'Minutos'),
                items: [for (final m in const ['00', '15', '30', '45']) DropdownMenuItem(value: m, child: Text(':$m'))],
                onChanged: (m) => _setTime(minutes: m),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: DropdownButtonFormField<bool>(
                isExpanded: true,
                initialValue: _pm,
                decoration: const InputDecoration(labelText: 'a.m./p.m.'),
                items: const [DropdownMenuItem(value: false, child: Text('a.m.')), DropdownMenuItem(value: true, child: Text('p.m.'))],
                onChanged: (pm) => _setTime(pm: pm),
              ),
            ),
          ],
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
