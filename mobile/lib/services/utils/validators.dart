/// Validadores de formularios. Siguen las mismas reglas que la API (backend/src/services/password.service.ts).
abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? required(String? v, [String message = 'Este campo es obligatorio.']) => (v == null || v.trim().isEmpty) ? message : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Escribe tu correo electrónico.';
    if (!_email.hasMatch(v.trim())) return 'Escribe un correo válido, por ejemplo nombre@correo.com.';
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().length < 2) return 'Escribe tu nombre completo.';
    return null;
  }

  static String? phone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Escribe tu teléfono.';
    if (digits.length < 10) return 'El teléfono debe tener al menos 10 dígitos.';
    return null;
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
