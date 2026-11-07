import 'package:intl/intl.dart';

/// Formatos de moneda y fecha en español de México.
abstract final class Fmt {
  static const _locale = 'es_MX';
  static final _money = NumberFormat.currency(locale: _locale, symbol: r'$', decimalDigits: 0);
  static final _moneyCents = NumberFormat.currency(locale: _locale, symbol: r'$', decimalDigits: 2);

  /// 12000 → "$12,000"; 1840.5 → "$1,840.50"
  static String money(num value) => (value % 1 == 0 ? _money : _moneyCents).format(value);

  /// Fechas de la API (AAAA-MM-DD o ISO). Las horas se muestran SIEMPRE en hora de Cancún (UTC-5, sin horario de verano),
  /// aunque el teléfono esté en otra zona (p. ej. hora del centro, UTC-6): así coinciden con el sitio, el panel y lo que se eligió.
  static DateTime parse(String value) => value.length == 10 ? DateTime.parse('${value}T12:00:00') : _cancun(DateTime.parse(value));

  /// «Ahora» en Cancún, para comparar con las horas de las citas (que también están en hora de Cancún).
  static DateTime now() => _cancun(DateTime.now());

  /// Una hora elegida en pantalla (hora de Cancún) para la API: 2026-11-25T11:00:00-05:00
  static String cancunIso(DateTime wall) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${wall.year}-${two(wall.month)}-${two(wall.day)}T${two(wall.hour)}:${two(wall.minute)}:00-05:00';
  }

  static DateTime _cancun(DateTime instant) {
    final u = instant.toUtc().subtract(const Duration(hours: 5));
    return DateTime(u.year, u.month, u.day, u.hour, u.minute, u.second, u.millisecond);
  }

  /// "5 de noviembre"
  static String dayMonth(DateTime d) => DateFormat("d 'de' MMMM", _locale).format(d);

  /// "5 nov"
  static String dayMonthShort(DateTime d) => DateFormat('d MMM', _locale).format(d).replaceAll('.', '');

  /// "15 de marzo de 1995"
  static String longDate(DateTime d) => DateFormat("d 'de' MMMM 'de' y", _locale).format(d);

  /// "30 jun 2027"
  static String shortDate(DateTime d) => DateFormat('d MMM y', _locale).format(d).replaceAll('.', '');

  /// "Jue - 16 Oct 5:00 pm"
  static String appointment(DateTime d) {
    final day = _cap(DateFormat('EEE', _locale).format(d).replaceAll('.', ''));
    final month = _cap(DateFormat('MMM', _locale).format(d).replaceAll('.', ''));
    return '$day - ${d.day} $month ${time(d)}';
  }

  /// "5:00 p.m." (de 1 a 12 con a.m./p.m.)
  static String time(DateTime d) => '${d.hour % 12 == 0 ? 12 : d.hour % 12}:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'a.m.' : 'p.m.'}';

  /// "15:30" → "3:30 p.m."
  static String hhmm(String value) {
    final p = value.split(':');
    final h = int.tryParse(p.first);
    if (h == null || p.length < 2) return value;
    return time(DateTime(2000, 1, 1, h, int.tryParse(p[1].substring(0, 2)) ?? 0));
  }

  /// Primer nombre para el saludo.
  static String firstName(String name) => name.trim().split(RegExp(r'\s+')).first;

  /// Iniciales para el avatar: "Laura Mendez" → "LM".
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
