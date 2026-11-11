/// Validadores de formularios. Siguen las mismas reglas que la API (backend/src/services/password.service.ts).
abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? required(String? v, [String message = 'Este campo es obligatorio.']) => (v == null || v.trim().isEmpty) ? message : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Escribe tu correo electrónico.';
    if (!_email.hasMatch(v.trim())) return 'Escribe un correo válido, por ejemplo nombre@correo.com.';
    return null;
  }

  /// Nombre y al menos un apellido, solo con letras.
  static String? name(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Escribe tu nombre completo.';
    if (_notLetters.hasMatch(s)) return 'Escribe solo letras.';
    if (s.split(RegExp(r'\s+')).length < 2) return 'Escribe tu nombre y al menos un apellido.';
    return text(s, min: 5, max: 80);
  }

  /// 10 dígitos; también se acepta con la lada del país: +52 998 000 0000.
  static String? phone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^52(?=\d{10}$)'), '');
    if (digits.isEmpty) return 'Escribe tu teléfono.';
    if (digits.length != 10) return 'El teléfono debe tener 10 dígitos (llevas ${digits.length}).';
    return null;
  }

  static final _notLetters = RegExp(r"[^\p{L}\s.'-]", unicode: true);

  /// Texto con mínimo y máximo de caracteres. [empty] es el mensaje si falta; sin él, el campo es opcional.
  static String? text(String? v, {required int min, required int max, String? empty}) {
    final n = (v ?? '').trim().length;
    if (n == 0) return empty;
    if (n < min) return 'Escribe al menos $min caracteres.';
    return n > max ? 'Escribe máximo $max caracteres.' : null;
  }

  /// Nacionalidad y datos parecidos: solo letras.
  static String? words(String? v, {required int min, required int max, String? empty}) =>
      _notLetters.hasMatch((v ?? '').trim()) ? 'Escribe solo letras.' : text(v, min: min, max: max, empty: empty);

  static String _money(int n) => '\$${n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

  /// Presupuesto mínimo (opcional): su error sale en su propio campo.
  static String? budgetMin(String? minText, {required bool sale}) {
    final low = sale ? 100000 : 1000;
    final min = int.tryParse((minText ?? '').trim());
    return min != null && min < low ? 'Debe ser de al menos ${_money(low)}.' : null;
  }

  /// Presupuesto máximo: una renta al mes y una compra no se miden igual (mismos límites que el sitio).
  static String? budget(String? maxText, {String? minText, required bool sale}) {
    final low = sale ? 100000 : 1000, high = sale ? 999999999 : 1000000;
    final min = int.tryParse((minText ?? '').trim()), max = int.tryParse((maxText ?? '').trim());
    if (max == null || max <= 0) return 'Escribe tu presupuesto máximo.';
    if (max < low) return 'Debe ser de al menos ${_money(low)}.';
    if (max > high) return 'No puede pasar de ${_money(high)}.';
    if (min != null && min > max) return 'No puede ser menor que el mínimo.';
    return null;
  }

  /// Cantidad opcional dentro de un rango (metros, precio esperado).
  static String? amount(String? v, {required int min, required int max, required String unit}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null;
    final n = int.tryParse(s) ?? 0;
    if (n < min) return 'Debe ser de al menos $min $unit.';
    return n > max ? 'No puede pasar de $max $unit.' : null;
  }

  /// Política: mínimo 8 caracteres, con mayúscula, minúscula y número.
  static String? password(String? v) {
    final p = v ?? '';
    if (p.isEmpty) return 'Escribe una contraseña.';
    final missing = passwordMissing(p);
    return missing.isEmpty ? null : 'La contraseña debe tener ${missing.join(', ')}.';
  }

  /// Lo que le falta a la contraseña (para el indicador de seguridad).
  static List<String> passwordMissing(String p) => [
        if (p.length < 8) 'al menos 8 caracteres',
        if (!RegExp(r'[A-ZÁÉÍÓÚÑ]').hasMatch(p)) 'una mayúscula',
        if (!RegExp(r'[a-záéíóúñ]').hasMatch(p)) 'una minúscula',
        if (!RegExp(r'\d').hasMatch(p)) 'un número',
      ];

  /// 0 a 4 según las reglas cumplidas (+1 si tiene 12 caracteres o un símbolo).
  static int passwordStrength(String p) {
    if (p.isEmpty) return 0;
    var score = 4 - passwordMissing(p).length;
    if (score == 4 && (p.length >= 12 || RegExp(r'[^\w\s]').hasMatch(p))) score = 5;
    return score.clamp(0, 5);
  }
}
