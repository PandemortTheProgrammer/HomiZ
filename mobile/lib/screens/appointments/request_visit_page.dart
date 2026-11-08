import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/states.dart';
import '../../models/property_models.dart';
import '../../services/providers/property_provider.dart';
import '../../widgets/property/property_widgets.dart';
import '../../services/providers/requests_provider.dart';
import '../../services/providers/appointments_provider.dart';
import '../../services/providers/pending_visit_provider.dart';

/// Ficha de una casa del catálogo con el formulario para solicitar visita.
class RequestVisitPage extends ConsumerWidget {
  const RequestVisitPage({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final property = ref.watch(propertyDetailProvider(propertyId));
    return Scaffold(
      appBar: AppBar(),
      body: switch (property) {
        AsyncData(:final value) => _VisitForm(property: value),
        AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(propertyDetailProvider(propertyId))),
        _ => const LoadingState(items: 3, itemHeight: 120),
      },
    );
  }
}

/// Casa elegida en el sitio de Zugar («Usar la app»): se busca por su slug y se muestra el mismo formulario.
class VisitFromSitePage extends ConsumerStatefulWidget {
  const VisitFromSitePage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<VisitFromSitePage> createState() => _VisitFromSitePageState();
}

class _VisitFromSitePageState extends ConsumerState<VisitFromSitePage> {
  @override
  void initState() {
    super.initState();
    // Ya llegó a la casa: al volver a entrar a la app no se redirige otra vez.
    Future.microtask(() => ref.read(pendingVisitProvider.notifier).clear());
  }

  @override
  Widget build(BuildContext context) {
    final property = ref.watch(propertyBySlugProvider(widget.slug));
    return Scaffold(
      appBar: AppBar(),
      body: switch (property) {
        AsyncData(value: final PropertyDetail p) => _VisitForm(property: p),
        AsyncData() => EmptyState(
          icon: Icons.home_work_outlined,
          title: 'Esta casa ya no está disponible',
          message: 'Puede que ya se haya rentado o vendido. Mira otras casas del catálogo.',
          actionLabel: 'Ver catálogo',
          onAction: () => context.go('/appointments/catalog'),
        ),
        AsyncError(:final error) => ErrorState(error: error, onRetry: () => ref.invalidate(propertyBySlugProvider(widget.slug))),
        _ => const LoadingState(items: 3, itemHeight: 120),
      },
    );
  }
}

class _VisitForm extends ConsumerStatefulWidget {
  const _VisitForm({required this.property});

  final PropertyDetail property;

  @override
  ConsumerState<_VisitForm> createState() => _VisitFormState();
}

/// El mismo formulario de la casa en el sitio: presupuesto máximo, personas, mascotas, nacionalidad, ocupación
/// (y forma de pago si es venta), día y hora. Nombre, correo y teléfono salen de la cuenta.
class _VisitFormState extends ConsumerState<_VisitForm> {
  final _form = GlobalKey<FormState>();
  DateTime? _date;
  TimeOfDay? _time;
  final _note = TextEditingController();
  late final _budget = TextEditingController(text: widget.property.price > 0 ? widget.property.price.round().toString() : '');
  final _nationality = TextEditingController();
  final _job = TextEditingController();
  final _petsDetail = TextEditingController();
  String _people = '2';
  bool? _pets;
  String? _payment;
  bool _loading = false;
  String? _error;

  static const _payments = {'contado': 'De contado', 'credito': 'Crédito bancario', 'infonavit': 'Infonavit', 'otro': 'Otra forma'};

  bool get _sale => widget.property.operation == 'venta';

  @override
  void dispose() {
    for (final c in [_note, _budget, _nationality, _job, _petsDetail]) {
      c.dispose();
    }
    super.dispose();
  }

  DateTime? get _scheduledAt => _date == null || _time == null ? null : DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);

  Future<void> _pickDate() async {
    final now = Fmt.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Elige el día de la visita',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 11, minute: 0),
      helpText: 'Elige la hora (bloques de 15 min)',
    );
    if (picked == null) return;
    // La visita dura 15 minutos: se ajusta al bloque más cercano (:00, :15, :30, :45)
    final total = ((picked.hour * 60 + picked.minute) / 15).round() * 15;
    setState(() => _time = TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60));
  }

  Future<void> _submit() async {
    final valid = _form.currentState?.validate() ?? false;
    if (_pets == null) {
      setState(() => _error = 'Dinos si tienes mascotas.');
      return;
    }
    if (!valid) {
      setState(() => _error = 'Revisa los campos marcados.');
      return;
    }
    final when = _scheduledAt;
    if (when == null) {
      setState(() => _error = 'Elige el día y la hora de la visita.');
      return;
    }
    if (!when.isAfter(Fmt.now())) {
      setState(() => _error = 'Elige una fecha y hora futuras.');
      return;
    }
    final p = widget.property;
    if (p.code == null) {
      setState(() => _error = 'No pudimos identificar esta casa. Inténtalo desde el catálogo.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    String two(int n) => n.toString().padLeft(2, '0');
    final budget = int.tryParse(_budget.text) ?? 0;
    try {
      final moving = ref.read(activeAppointmentProvider).value != null;
      // Como el formulario de la casa en el sitio: la solicitud con todo lo que llenó y su cita (por confirmar)
      await ref
          .read(requestActionsProvider)
          .create(
            reason: _sale ? 'comprar' : 'rentar',
            message: _note.text,
            propertyCode: p.code,
            preferredDate: '${when.year}-${two(when.month)}-${two(when.day)}',
            preferredTime: '${two(when.hour)}:${two(when.minute)}',
            payload: {
              'presupuesto': '${Fmt.money(budget)} MXN${_sale ? '' : ' / mes'}',
              'presupuesto_max': budget,
              'personas': _people,
              'mascotas': _pets! ? 'si' : 'no',
              'mascotas_detalle': _pets! ? _petsDetail.text : null,
              'nacionalidad': _nationality.text,
              'ocupacion': _job.text,
              if (_sale) 'forma_pago': _payment,
            },
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(moving ? 'Cambiamos tu cita a esta casa. Te avisaremos cuando se confirme.' : 'Solicitamos tu visita. Te avisaremos cuando se confirme.')));
      context.go('/appointments');
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    // Una cita a la vez: si ya tiene una, esta visita la cambia (no se crea otra)
    final active = ref.watch(activeAppointmentProvider).value;
    final sameHouse = active?.property.id == p.id;
    InputDecoration field(String label, {String? hint, String? helper}) => InputDecoration(labelText: label, hintText: hint, helperText: helper, helperMaxLines: 3);
    String? required(String? v, String msg) => (v ?? '').trim().length < 2 ? msg : null;
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xxl),
        children: [
          PropertyHero(
            url: p.coverUrl,
            height: 210,
            overlay: HeroCaption(title: p.name, location: [p.zone, p.city].whereType<String>().join(', ')),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('${Fmt.money(p.price)}${p.operation == 'renta' ? ' / mes' : ''}', style: AppTextStyles.pageTitle.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          FeatureRow(rec: p.rec, banos: p.banos, amenities: p.amenities),
          if (p.description != null) ...[const SizedBox(height: AppSpacing.md), Text(p.description!, style: AppTextStyles.body.copyWith(color: AppColors.textMuted))],
          const SizedBox(height: AppSpacing.xl),
          Text(active == null ? '¿Te gustaría agendar una cita?' : (sameHouse ? 'Cambiar la fecha de tu cita' : 'Cambiar tu cita a esta casa'), style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          if (active != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Ya tienes la cita ${active.code}${sameHouse ? '' : ' en ${active.property.name}'} el ${Fmt.dayMonth(active.scheduledAt)} a las ${Fmt.time(active.scheduledAt)}. '
                'Tienes una cita a la vez: al enviar, ${sameHouse ? 'cambiamos su fecha y hora' : 'esa cita pasa a esta casa'} y queda por confirmar.',
                style: AppTextStyles.body.copyWith(fontSize: 13),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // Lo mismo que pide el formulario de la casa en el sitio
          TextFormField(
            controller: _budget,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 12,
            decoration: field(
              _sale ? 'Presupuesto máximo' : 'Presupuesto máximo al mes',
              helper: 'Lo más que quieres pagar. Con este límite te presentamos también cualquier otra casa que no lo pase.',
            ).copyWith(prefixText: r'$ ', suffixText: 'MXN', counterText: ''),
            validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Escribe tu presupuesto máximo.' : null,
          ),
          if (_sale) ...[
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _payment,
              decoration: field('¿Cómo planeas comprar?'),
              items: [for (final e in _payments.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
              onChanged: (v) => setState(() => _payment = v),
              validator: (v) => v == null ? 'Elige cómo planeas comprar.' : null,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _people,
            decoration: field('Personas que vivirán en la casa'),
            items: [
              for (final n in const ['1', '2', '3', '4', '5']) DropdownMenuItem(value: n, child: Text(n == '5' ? '5 o más' : n)),
            ],
            onChanged: (v) => setState(() => _people = v ?? '2'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('¿Tienes mascotas?', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Sí')),
              ButtonSegment(value: false, label: Text('No')),
            ],
            emptySelectionAllowed: true,
            selected: {?_pets},
            onSelectionChanged: _loading ? null : (s) => setState(() => _pets = s.firstOrNull),
          ),
          if (_pets == true) ...[
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _petsDetail,
              maxLength: 200,
              decoration: field('¿Cuáles y cuántas?', hint: 'Por ejemplo: 1 perro pequeño'),
              validator: (v) => _pets == true && (v ?? '').trim().isEmpty ? 'Cuéntanos qué mascotas tienes.' : null,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _nationality,
            maxLength: 60,
            decoration: field('Nacionalidad', hint: 'Mexicana').copyWith(counterText: ''),
            validator: (v) => required(v, 'Escribe tu nacionalidad.'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _job,
            maxLength: 80,
            decoration: field('¿En qué trabajas?', hint: 'Por ejemplo: diseño de interiores').copyWith(counterText: ''),
            validator: (v) => required(v, 'Cuéntanos en qué trabajas.'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Día y hora de la visita (15 minutos)', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(onPressed: _loading ? null : _pickDate, icon: const Icon(Icons.event_outlined), label: Text(_date == null ? 'Día' : Fmt.dayMonth(_date!))),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _pickTime,
                  icon: const Icon(Icons.schedule_outlined),
                  label: Text(_time == null ? 'Hora' : Fmt.time(DateTime(2000, 1, 1, _time!.hour, _time!.minute))),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _note,
            maxLines: 3,
            maxLength: 1000,
            decoration: const InputDecoration(labelText: 'Comentarios (opcional)', hintText: 'Lo que te gustaría ver en la visita'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Semantics(
                liveRegion: true,
                child: Text(_error!, style: AppTextStyles.secondary.copyWith(color: AppColors.danger, fontSize: 13)),
              ),
            ),
          PrimaryButton(label: active == null ? 'Solicitar visita' : (sameHouse ? 'Cambiar fecha de mi cita' : 'Cambiar mi cita a esta casa'), loading: _loading, onPressed: _submit),
        ],
      ),
    );
  }
}
