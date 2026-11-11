import 'package:flutter/material.dart';


/// Horario de visitas de la inmobiliaria: de 7:00 a.m. a 10:45 p.m., en bloques de 15 minutos (termina a las 11:00 p.m.).
final visitTimes = [
  for (var m = 7 * 60; m < 23 * 60; m += 15) '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}',
];

/// Reloj para elegir la hora en formato de 12 horas (a.m./p.m.). Se ajusta a bloques de 15 minutos
/// y solo acepta el horario de visitas; fuera de él avisa y devuelve null.
Future<TimeOfDay?> pickVisitTime(BuildContext context, {TimeOfDay? initial, String title = 'Hora de la visita'}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final picked = await showTimePicker(
    context: context,
    initialTime: initial ?? const TimeOfDay(hour: 11, minute: 0),
    initialEntryMode: TimePickerEntryMode.dial,
    helpText: title,
    // México usa 24 horas por omisión en este selector: español con a.m./p.m.
    builder: (context, child) => Localizations.override(
      context: context,
      locale: const Locale('es', 'US'),
      child: MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), child: child!),
    ),
  );
  if (picked == null) return null;
  final total = ((picked.hour * 60 + picked.minute) / 15).round() * 15; // bloques de 15 minutos
  if (total < 7 * 60 || total > 22 * 60 + 45) {
    messenger?.showSnackBar(const SnackBar(content: Text('Las visitas son de 7:00 a.m. a 11:00 p.m.')));
    return null;
  }
  return TimeOfDay(hour: total ~/ 60, minute: total % 60);
}
