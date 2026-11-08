import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/cards.dart';
import '../../services/repositories/requests_repository.dart';

/// Nombres legibles de los campos del formulario
const _fieldNames = {
  'operacion': 'Operación', 'tipo_inmueble': 'Tipo de inmueble', 'presupuesto': 'Presupuesto', 'presupuesto_min': 'Mínimo', 'presupuesto_max': 'Máximo', 'fecha_preferida': 'Fecha para visitar', 'horario': 'Horario', 'recamaras': 'Recámaras', 'banos': 'Baños', 'personas': 'Personas',
  'mascotas': 'Mascotas', 'mascotas_detalle': 'Cuáles mascotas', 'zona': 'Ubicación', 'nacionalidad': 'Nacionalidad', 'ocupacion': 'Ocupación',
  'inmueble_zona': 'Colonia', 'inmueble_precio': 'Precio esperado', 'inmueble_recamaras': 'Recámaras', 'inmueble_tipo': 'Tipo', 'inmueble_operacion': 'Quiere',
  'mudanza': 'Quiere mudarse', 'plazo_renta': 'Tiempo de renta', 'forma_pago': 'Forma de pago', 'inmueble_banos': 'Baños', 'inmueble_m2': 'Metros cuadrados', 'inmueble_disponible': 'Disponible', 'asunto': 'Asunto',
};

/// Grupos del formulario, en el orden en que se llenó. Lo que no esté aquí sale en «Otros datos».
const _groups = [
  ('Asunto', ['asunto']),
  ('Qué busca', ['operacion', 'tipo_inmueble', 'presupuesto_min', 'presupuesto_max', 'presupuesto', 'recamaras', 'banos', 'personas', 'mascotas', 'mascotas_detalle', 'zona', 'ubicacion', 'mudanza', 'plazo_renta', 'forma_pago']),
  ('Sobre la persona', ['nacionalidad', 'ocupacion']),
  ('Su casa para publicar', ['inmueble_tipo', 'inmueble_operacion', 'inmueble_zona', 'inmueble_recamaras', 'inmueble_banos', 'inmueble_m2', 'inmueble_disponible', 'inmueble_precio']),
  ('Visita', ['fecha_preferida', 'horario']),
];
const _values = {'si': 'Sí', 'no': 'No', 'true': 'Sí', 'false': 'No', 'renta': 'Renta', 'compra': 'Compra', 'venta': 'Venta', 'ambas': 'Aún no lo decide', 'casa': 'Casa', 'casa-condominio': 'Casa en condominio', 'townhouse': 'Townhouse'};
const _money = {'presupuesto_min', 'presupuesto_max', 'inmueble_precio'};
const _origins = {'app': 'App Homiz', 'panel': 'Registrada en el panel'};

String _shown(String key, String value) {
  final n = num.tryParse(value);
  if (_money.contains(key) && n != null) return Fmt.money(n);
  return _values[value] ?? value;
}

/// Todo lo que llenó en el formulario, por secciones. El personal ve además sus datos de contacto.
/// Se usa en el detalle de la solicitud y en el de la cita.
class RequestFormSections extends StatelessWidget {
  const RequestFormSections({super.key, required this.request, required this.staff});

  final LeadRequest request;
  final bool staff;

  @override
  Widget build(BuildContext context) {
    final r = request;
    final p = r.payload;
    final filled = {for (final e in p.entries) if (e.value.isNotEmpty && e.value != 'null') e.key: e.value};
    // Con el rango numérico, el texto «presupuesto» repite lo mismo
    final skip = {'origen', if (filled.containsKey('presupuesto_min') || filled.containsKey('presupuesto_max')) 'presupuesto'};
    final known = {for (final g in _groups) ...g.$2};
    final sections = <(String, List<(String, String)>)>[
      if (staff)
        ('Contacto', [
          ('Nombre', r.name ?? '—'),
          ('Correo', r.email ?? '—'),
          ('Teléfono', r.phone ?? '—'),
          ('Llegó por', _origins[p['origen']] ?? 'Sitio web'),
          ('Fecha', Fmt.dayMonthShort(r.createdAt)),
        ]),
      for (final (title, keys) in _groups)
        (title, [
          if (title == 'Visita') ...[
            if (r.propertyName != null) ('Casa', r.propertyName!),
            if (r.preferredDate != null) ('Fecha preferida', Fmt.dayMonthShort(DateTime.parse(r.preferredDate!))),
            if (r.preferredTime != null) ('Horario', Fmt.hhmm(r.preferredTime!)),
          ],
          for (final k in keys)
            if (filled.containsKey(k) && !skip.contains(k)) (_fieldNames[k] ?? k, _shown(k, filled[k]!)),
        ]),
      ('Otros datos', [
        for (final e in filled.entries)
          if (!known.contains(e.key) && !skip.contains(e.key)) (_fieldNames[e.key] ?? e.key.replaceAll('_', ' '), _shown(e.key, e.value)),
      ]),
    ].where((s) => s.$2.isNotEmpty).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.cardAll, border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (title, rows) in sections) ...[
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(title.toUpperCase(), style: AppTextStyles.small.copyWith(color: AppColors.textMuted, letterSpacing: 0.6)),
            ),
            for (final (i, (label, value)) in rows.indexed) KeyValueRow(label: label, value: value, showDivider: i < rows.length - 1),
          ],
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text('MENSAJE', style: AppTextStyles.small.copyWith(color: AppColors.textMuted, letterSpacing: 0.6)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(r.message != null ? '«${r.message!}»' : 'No escribió mensaje.', style: r.message != null ? AppTextStyles.body : AppTextStyles.secondary),
          ),
        ],
      ),
    );
  }
}
