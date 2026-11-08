import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../../services/utils/property_types.dart';
import '../../widgets/common/primary_button.dart';
import '../../services/providers/appointments_provider.dart';
import '../../services/providers/pending_visit_provider.dart';
import '../../services/providers/session_provider.dart';
import '../../services/providers/site_link_provider.dart';
import '../../services/providers/property_provider.dart';
import '../../services/providers/requests_provider.dart';

/// «¿Qué quieres hacer?»: el mismo formulario de «Contáctanos» del sitio (rentar, comprar, publicar u otro).
/// Se abre solo al crear una cuenta o al entrar por primera vez desde un QR del sitio ([welcome]); con [slug] (QR de una casa)
/// la casa queda como «de interés» y se puede agendar la cita en el mismo paso.
/// Los datos de contacto salen de la cuenta. La ubicación se escribe libre.
/// Las mismas opciones del formulario del sitio (web/src/pages/Contact.tsx)
const _moveIn = ['Lo antes posible', 'En 1 a 3 meses', 'En más de 3 meses', 'Solo estoy viendo opciones'];
const _rentTerm = ['6 meses', '1 año', '2 años o más', 'Aún no lo sé'];
const _payment = ['Contado', 'Crédito bancario', 'Infonavit', 'Fovissste', 'Aún no lo sé'];
const _available = ['Ya está disponible', 'En menos de 3 meses', 'Más adelante'];
const _subjects = ['Asesoría para elegir zona', 'Avalúo de mi propiedad', 'Administración de mi propiedad', 'Aclaración o queja', 'Otro tema'];

class NewRequestPage extends ConsumerStatefulWidget {
  const NewRequestPage({super.key, this.slug, this.welcome = false});

  final String? slug;
  final bool welcome;

  @override
  ConsumerState<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends ConsumerState<NewRequestPage> {
  final _form = GlobalKey<FormState>();
  final _place = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();
  final _nationality = TextEditingController();
  final _job = TextEditingController();
  final _petsDetail = TextEditingController();
  final _price = TextEditingController();
  final _meters = TextEditingController();
  final _message = TextEditingController();
  String _reason = 'rentar';
  String? _type;
  String _rooms = '3';
  String _baths = '2';
  String _people = '2';
  bool _pets = false;
  String _publishOp = 'renta';
  String _publishBaths = '2';
  String? _moveInWhen;
  String? _term;
  String? _pay;
  String? _availableWhen;
  String? _subject;
  bool _visit = true;
  DateTime? _date;
  TimeOfDay? _time;
  bool _loading = false;
  bool _reasonFromHouse = false;
  String? _error;

  bool get _looking => _reason == 'rentar' || _reason == 'comprar';

  @override
  void initState() {
    super.initState();
    // Ya llegó al formulario: el enlace del QR no se vuelve a usar al entrar otra vez
    Future.microtask(() {
      ref.read(pendingVisitProvider.notifier).clear();
      ref.read(siteLinkProvider.notifier).clear();
      ref.read(sessionProvider.notifier).justRegistered = false;
    });
  }

  @override
  void dispose() {
    for (final c in [_place, _min, _max, _nationality, _job, _petsDetail, _price, _meters, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  /// «15000» → 15000 (solo números); vacío → null
  static int? _amount(String v) => int.tryParse(v.replaceAll(RegExp(r'[^\d]'), ''));
  static String _fmt(int n) => '\$${n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

  /// «$10,000 – $20,000 MXN / mes» para que el asesor lo lea de un vistazo
  String _budgetLabel() {
    final a = _amount(_min.text), b = _amount(_max.text);
    final unit = _reason == 'comprar' ? ' MXN' : ' MXN / mes';
    if (a != null && b != null) return '${_fmt(a)} – ${_fmt(b)}$unit';
    return b != null ? 'Hasta ${_fmt(b)}$unit' : a != null ? 'Desde ${_fmt(a)}$unit' : '';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      helpText: 'Día de tu cita',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 11, minute: 0),
      helpText: 'Hora de tu cita (la visita dura 15 min)',
    );
    if (picked == null) return;
    final total = ((picked.hour * 60 + picked.minute) / 15).round() * 15; // bloques de 15 minutos
    setState(() => _time = TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60));
  }

  Future<void> _submit(String? slug) async {
    if (!_form.currentState!.validate()) return setState(() => _error = 'Revisa los campos marcados en rojo.');
    final withVisit = slug != null && _looking && _visit;
    if (withVisit && (_date == null || _time == null)) return setState(() => _error = 'Elige el día y la hora de tu cita, o desactiva «Quiero agendar una cita».');
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    String two(int n) => n.toString().padLeft(2, '0');
    try {
      final r = await ref.read(requestActionsProvider).create(
            reason: _reason,
            message: _message.text,
            propertySlug: _looking ? slug : null,
            preferredDate: withVisit ? '${_date!.year}-${two(_date!.month)}-${two(_date!.day)}' : null,
            preferredTime: withVisit ? '${two(_time!.hour)}:${two(_time!.minute)}' : null,
            payload: {
              if (_looking) ...{
                'operacion': _reason == 'comprar' ? 'compra' : 'renta',
                'tipo_inmueble': _type,
                'zona': _place.text,
                'presupuesto': _budgetLabel(),
                'presupuesto_min': _amount(_min.text),
                'presupuesto_max': _amount(_max.text),
                'recamaras': _rooms,
                'banos': _baths,
                'personas': _people,
                'mascotas': _pets ? 'si' : 'no',
                'mascotas_detalle': _pets ? _petsDetail.text : null,
                'mudanza': _moveInWhen,
                if (_reason == 'rentar') ...{'nacionalidad': _nationality.text, 'ocupacion': _job.text, 'plazo_renta': _term},
                if (_reason == 'comprar') 'forma_pago': _pay,
              },
              if (_reason == 'publicar') ...{
                'inmueble_tipo': _type ?? 'Casa',
                'inmueble_operacion': _publishOp,
                'inmueble_zona': _place.text,
                'inmueble_recamaras': _rooms,
                'inmueble_banos': _publishBaths,
                'inmueble_m2': _amount(_meters.text),
                'inmueble_disponible': _availableWhen,
                'inmueble_precio': _amount(_price.text),
              },
              if (_reason == 'otro') 'asunto': _subject,
            },
          );
      if (!mounted) return;
      ref.invalidate(appointmentsProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(withVisit
            ? 'Listo: pedimos tu cita (folio ${r.folio}). Te avisaremos aquí cuando tu asesor la confirme.'
            : 'Recibimos tu solicitud (folio ${r.folio}). Tu asesor te contestará aquí.'),
      ));
      if (withVisit) {
        context.go('/appointments');
      } else {
        context.pushReplacement('/home/requests/${r.id}');
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _choice(String label, List<(String, String)> options, String value, ValueChanged<String> onChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<String>(
            segments: [for (final (v, t) in options) ButtonSegment(value: v, label: Text(t))],
            selected: {value},
            showSelectedIcon: false,
            onSelectionChanged: _loading ? null : (s) => onChanged(s.first),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      );

  /// Título de cada parte del formulario, como los bloques del sitio
  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
        child: Text(title, style: AppTextStyles.sectionTitle),
      );

  /// Lista opcional: «Sin definir» deja el dato vacío
  Widget _optional(String label, List<String> options, String? value, ValueChanged<String?> onChanged) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: DropdownButtonFormField<String?>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Sin definir')),
            for (final o in options) DropdownMenuItem<String?>(value: o, child: Text(o, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: _loading ? null : onChanged,
        ),
      );

  Widget _typeField({required bool any}) => DropdownButtonFormField<String?>(
        initialValue: _type,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Tipo de inmueble'),
        items: [
          if (any) const DropdownMenuItem<String?>(value: null, child: Text('Cualquiera')),
          for (final (group, name) in propertyTypes) DropdownMenuItem<String?>(value: name, child: Text('$name · $group', overflow: TextOverflow.ellipsis)),
        ],
        onChanged: _loading ? null : (v) => setState(() => _type = v),
      );

  @override
  Widget build(BuildContext context) {
    final house = widget.slug == null ? null : ref.watch(propertyBySlugProvider(widget.slug!)).value;
    // La operación de la casa del QR decide si quiere rentar o comprar (se puede cambiar)
    if (house != null && !_reasonFromHouse) {
      _reasonFromHouse = true;
      _reason = house.operation == 'venta' ? 'comprar' : 'rentar';
    }
    final slug = house == null ? null : widget.slug;
    return Scaffold(
      appBar: AppBar(title: Text(widget.welcome ? 'Bienvenido a Homiz' : 'Nueva solicitud')),
      body: Form(
        key: _form,
        // Columna y no ListView: la lista no construye lo que está fuera de pantalla y esos campos no se validarían
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.screen, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('¿Qué quieres hacer?', style: AppTextStyles.pageTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Cuéntanos qué buscas y tu asesor te propondrá propiedades aquí en la app. Tus datos de contacto ya los tenemos de tu cuenta.',
                style: AppTextStyles.secondary.copyWith(fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final (v, label) in const [('rentar', 'Rentar'), ('comprar', 'Comprar'), ('publicar', 'Publicar mi propiedad'), ('otro', 'Otro')])
                    ChoiceChip(label: Text(label), selected: _reason == v, onSelected: _loading ? null : (_) => setState(() => _reason = v)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (house != null && _looking) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Propiedad de interés', style: AppTextStyles.label),
                      Text('${house.name} · ${Fmt.money(house.price)}${house.operation == 'renta' ? ' / mes' : ''}', style: AppTextStyles.cardTitle),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _visit,
                        onChanged: _loading ? null : (v) => setState(() => _visit = v),
                        title: const Text('¿Te gustaría agendar una cita?'),
                      ),
                      if (_visit)
                        Row(
                          children: [
                            Expanded(child: OutlinedButton.icon(onPressed: _loading ? null : _pickDate, icon: const Icon(Icons.event_outlined), label: Text(_date == null ? 'Día' : Fmt.dayMonth(_date!)))),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _pickTime,
                                icon: const Icon(Icons.schedule_outlined),
                                label: Text(_time == null ? 'Hora' : Fmt.time(DateTime(2000, 1, 1, _time!.hour, _time!.minute))),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (_looking) ...[
                _section('La casa que buscas'),
                _typeField(any: true),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _place,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: house != null ? 'Otra zona de preferencia (opcional)' : 'Zona de preferencia', hintText: 'Colonia, ciudad o país'),
                  validator: (v) => house == null && (v ?? '').trim().length < 2 ? 'Escribe la zona que buscas.' : null,
                ),
                Text(_reason == 'comprar' ? 'Presupuesto (MXN)' : 'Presupuesto al mes (MXN)', style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text('El máximo es lo más que quieres pagar: con ese límite te presentamos cualquier casa que no lo pase.', style: AppTextStyles.secondary.copyWith(fontSize: 13)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _min,
                        maxLength: 12,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Mínimo', prefixText: r'$ ', counterText: '', helperText: 'Opcional'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _max,
                        maxLength: 12,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Máximo (tu límite)', prefixText: r'$ ', counterText: ''),
                        validator: (v) {
                          final max = _amount(v ?? ''), min = _amount(_min.text);
                          if (max == null || max <= 0) return 'Escribe tu presupuesto máximo.';
                          if (min != null && min > max) return 'El mínimo es mayor.';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final n in _reason == 'comprar' ? const [2000000, 3000000, 5000000, 7000000] : const [10000, 15000, 20000, 30000])
                      ActionChip(label: Text(_fmt(n)), onPressed: _loading ? null : () => setState(() => _max.text = '$n')),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _choice('Recámaras', const [('1', '1'), ('2', '2'), ('3', '3'), ('4', '4+')], _rooms, (v) => setState(() => _rooms = v)),
                _choice('Baños', const [('1', '1'), ('2', '2'), ('3', '3+')], _baths, (v) => setState(() => _baths = v)),
                _choice('Personas que vivirán', const [('1', '1'), ('2', '2'), ('3', '3'), ('4', '4'), ('5', '5+')], _people, (v) => setState(() => _people = v)),
                SwitchListTile(contentPadding: EdgeInsets.zero, value: _pets, onChanged: _loading ? null : (v) => setState(() => _pets = v), title: const Text('Tengo mascotas')),
                if (_pets)
                  TextFormField(
                    controller: _petsDetail,
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: '¿Cuáles y cuántas?', hintText: 'Por ejemplo: 1 perro pequeño'),
                    validator: (v) => _pets && (v ?? '').trim().isEmpty ? 'Cuéntanos qué mascotas tienes.' : null,
                  ),
                const SizedBox(height: AppSpacing.sm),
                _optional('¿Cuándo te gustaría mudarte?', _moveIn, _moveInWhen, (v) => setState(() => _moveInWhen = v)),
                if (_reason == 'comprar') _optional('¿Cómo pagarías la casa?', _payment, _pay, (v) => setState(() => _pay = v)),
                if (_reason == 'rentar') ...[
                  _optional('¿Por cuánto tiempo rentarías?', _rentTerm, _term, (v) => setState(() => _term = v)),
                  _section('Sobre ti'),
                  TextFormField(
                    controller: _nationality,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Nacionalidad', hintText: 'Mexicana'),
                    validator: (v) => (v ?? '').trim().length < 3 ? 'Escribe tu nacionalidad.' : null,
                  ),
                  TextFormField(
                    controller: _job,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: '¿En qué trabajas?'),
                    validator: (v) => (v ?? '').trim().length < 3 ? 'Cuéntanos en qué trabajas.' : null,
                  ),
                ],
              ],
              if (_reason == 'publicar') ...[
                _section('Tu propiedad'),
                _typeField(any: false),
                const SizedBox(height: AppSpacing.md),
                _choice('¿Qué quieres hacer con ella?', const [('renta', 'Rentarla'), ('venta', 'Venderla'), ('ambas', 'No sé')], _publishOp, (v) => setState(() => _publishOp = v)),
                TextFormField(
                  controller: _place,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Colonia o residencial'),
                  validator: (v) => (v ?? '').trim().length < 2 ? 'Escribe dónde está.' : null,
                ),
                _choice('Recámaras', const [('0', '0'), ('1', '1'), ('2', '2'), ('3', '3'), ('4', '4+')], _rooms, (v) => setState(() => _rooms = v)),
                _choice('Baños', const [('1', '1'), ('2', '2'), ('3', '3+')], _publishBaths, (v) => setState(() => _publishBaths = v)),
                TextFormField(
                  controller: _meters,
                  maxLength: 7,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Metros cuadrados (opcional)', counterText: '', suffixText: 'm²'),
                ),
                const SizedBox(height: AppSpacing.md),
                _optional('¿Cuándo está disponible?', _available, _availableWhen, (v) => setState(() => _availableWhen = v)),
                TextFormField(
                  controller: _price,
                  maxLength: 12,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Precio esperado (opcional)', prefixText: r'$ ', counterText: ''),
                ),
              ],
              _section('Tu mensaje'),
              if (_reason == 'otro') _optional('Asunto', _subjects, _subject, (v) => setState(() => _subject = v)),
              TextFormField(
                controller: _message,
                minLines: 3,
                maxLines: 6,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: _reason == 'otro' ? 'Tu mensaje' : 'Algo más que debamos saber (opcional)',
                  hintText: _reason == 'publicar' ? 'Estado de la propiedad, cuándo está disponible…' : 'Por ejemplo: cerca de escuelas, con jardín…',
                  alignLabelWithHint: true,
                ),
                validator: (v) => _reason == 'otro' && (v ?? '').trim().length < 5 ? 'Cuéntanos en qué te ayudamos.' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Semantics(liveRegion: true, child: Text(_error!, style: AppTextStyles.secondary.copyWith(color: AppColors.danger, fontSize: 13))),
                ),
              PrimaryButton(label: slug != null && _looking && _visit ? 'Enviar y pedir mi cita' : 'Enviar solicitud', loading: _loading, onPressed: () => _submit(slug)),
              if (widget.welcome) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(onPressed: _loading ? null : () => context.go('/home'), child: const Text('Ahora no, ver la app')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
