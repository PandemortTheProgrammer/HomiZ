import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';

/// Círculo con las iniciales del usuario («LM»).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.initials, this.size = 44});

  final String name;

  /// Iniciales calculadas por la API; si faltan se sacan del nombre.
  final String? initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final text = (initials?.isNotEmpty ?? false) ? initials! : Fmt.initials(name);
    return Semantics(
      label: name,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.avatarBg, shape: BoxShape.circle),
          child: Text(text, style: AppTextStyles.cardTitle.copyWith(color: AppColors.avatarText, fontSize: size * 0.36)),
        ),
      ),
    );
  }
}
