import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Campo de las pantallas de acceso: contorno blanco sobre el degradado, radio 10, etiqueta blanca.
/// Si [obscure] es true agrega el botón del ojo para mostrar u ocultar.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscure = false,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.inputFormatters,
    this.enabled = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscure;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Error que viene de la API para este campo.
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _hidden = widget.obscure;

  OutlineInputBorder _border(Color color, [double width = 1.2]) =>
      OutlineInputBorder(borderRadius: AppRadius.inputAll, borderSide: BorderSide(color: color, width: width));

  @override
  Widget build(BuildContext context) {
    const errorColor = Color(0xFFFFD2D2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label.copyWith(color: Colors.white)),
        const SizedBox(height: AppSpacing.xs + 2),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _hidden,
          autofillHints: widget.autofillHints,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          autocorrect: false,
          enableSuggestions: !widget.obscure,
          style: AppTextStyles.body.copyWith(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.body.copyWith(color: Colors.white60),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            errorText: widget.errorText,
            errorStyle: AppTextStyles.secondary.copyWith(color: errorColor),
            errorMaxLines: 3,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
            enabledBorder: _border(Colors.white70),
            focusedBorder: _border(Colors.white, 2),
            errorBorder: _border(errorColor),
            focusedErrorBorder: _border(errorColor, 2),
            disabledBorder: _border(Colors.white30),
            suffixIcon: widget.obscure
                ? IconButton(
                    tooltip: _hidden ? 'Mostrar contraseña' : 'Ocultar contraseña',
                    icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
