import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/validators.dart';

/// Indicador de seguridad de la contraseña (pantalla «Crea tu cuenta»). Pensado para el degradado.
class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final score = Validators.passwordStrength(password);
    final missing = Validators.passwordMissing(password);
    final (label, color) = switch (score) {
      0 => ('', Colors.white30),
      1 || 2 => ('Débil', AppColors.danger),
      3 => ('Regular', AppColors.badgePending),
      4 => ('Buena', AppColors.badgePaid),
      _ => ('Muy segura', AppColors.success),
    };
    return Semantics(
      label: label.isEmpty ? null : 'Seguridad de la contraseña: $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 5,
                    decoration: BoxDecoration(color: i < score ? color : Colors.white24, borderRadius: AppRadius.pillAll),
                  ),
                ),
              ],
            ],
          ),
          if (password.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            ExcludeSemantics(
              child: Text(
                missing.isEmpty ? label : '$label · falta ${missing.join(', ')}',
                style: AppTextStyles.secondary.copyWith(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
