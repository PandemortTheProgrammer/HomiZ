import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum ButtonVariant {
  /// Azul relleno, texto blanco.
  primary,

  /// Contorno azul, texto azul.
  outline,

  /// Fondo rosa, texto rojo («Cerrar sesión»).
  danger,

  /// Blanco con texto azul (sobre el degradado de acceso).
  white,
}

/// Botón en forma de píldora de ancho completo. Muestra un indicador mientras [loading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      ButtonVariant.primary => (AppColors.primary, Colors.white, AppColors.primary),
      ButtonVariant.outline => (Colors.transparent, AppColors.primary, AppColors.primary),
      ButtonVariant.danger => (AppColors.dangerBg, AppColors.danger, AppColors.dangerBg),
      ButtonVariant.white => (Colors.white, AppColors.primary, Colors.white),
    };
    final disabled = onPressed == null || loading;
    final child = loading
        ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: AppSpacing.sm)],
              Flexible(child: Text(label, style: AppTextStyles.button.copyWith(color: fg), overflow: TextOverflow.ellipsis)),
            ],
          );

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: SizedBox(
          width: expand ? double.infinity : null,
          height: AppSpacing.control,
          child: Material(
            color: bg,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll, side: BorderSide(color: border, width: 1.5)),
            child: InkWell(
              customBorder: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
              onTap: disabled ? null : onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Center(child: ExcludeSemantics(child: child)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
