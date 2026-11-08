import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Tarjeta gris de listas (expediente, pagarés, recibos, reportes) con texto blanco,
/// subtítulo de 1-2 líneas y un badge o botón «Ver» a la derecha.
class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.title, this.subtitle, this.trailing, this.onTap, this.caption});

  final String title;
  final String? subtitle;

  /// Texto extra en negritas bajo el título (p. ej. el monto «$12,000»).
  final String? caption;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardNeutral,
      borderRadius: AppRadius.cardAll,
      child: InkWell(
        borderRadius: AppRadius.cardAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle.copyWith(color: Colors.white)),
                    if (caption != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(caption!, style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontSize: 13)),
                    ],
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.secondary.copyWith(color: Colors.white)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: AppSpacing.md), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de resumen con barra de progreso verde (p. ej. «Estado de pagos»).
class SummaryProgressCard extends StatelessWidget {
  const SummaryProgressCard({super.key, required this.title, required this.lines, required this.progress});

  final String title;
  final List<String> lines;

  /// 0.0 a 1.0
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.cardNeutral, borderRadius: AppRadius.cardAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardTitle.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.sm),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Text(line, style: AppTextStyles.secondary.copyWith(color: Colors.white)),
            ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            label: 'Progreso ${(progress * 100).round()} por ciento',
            child: ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                color: AppColors.badgePaid,
                backgroundColor: AppColors.chipInactive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso informativo con pin morado («Esta información solo es para consulta…»).
class InfoNotice extends StatelessWidget {
  const InfoNotice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.push_pin_rounded, color: AppColors.notice, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTextStyles.secondary.copyWith(color: AppColors.textSecondary))),
      ],
    );
  }
}

/// Tarjeta azul del panel de inicio: título, fecha, detalle opcional e ilustración a la derecha.
class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.title, required this.value, this.detail, required this.illustration, this.onTap});

  final String title;
  final String value;
  final String? detail;

  /// Ruta del asset (.svg o .png) en assets/illustrations/.
  final String illustration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final art = illustration.endsWith('.svg')
        ? SvgPicture.asset(illustration, width: 92, height: 92, excludeFromSemantics: true)
        : Image.asset(illustration, width: 92, height: 92, excludeFromSemantics: true);
    return Material(
      color: AppColors.primaryCard,
      borderRadius: AppRadius.cardAll,
      elevation: 0,
      child: InkWell(
        borderRadius: AppRadius.cardAll,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 132),
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.sm, AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(value, style: AppTextStyles.greeting.copyWith(color: Colors.white, fontSize: 22)),
                    if (detail != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(detail!, style: AppTextStyles.secondary.copyWith(color: Colors.white70)),
                    ],
                  ],
                ),
              ),
              art,
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila clave/valor con separador (Nombre, Presupuesto, Mascotas…).
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({super.key, required this.label, required this.value, this.showDivider = true});

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(label, style: AppTextStyles.secondary.copyWith(fontSize: 13))),
              const SizedBox(width: AppSpacing.md),
              Flexible(child: Text(value, textAlign: TextAlign.right, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w500))),
            ],
          ),
        ),
        if (showDivider) const Divider(),
      ],
    );
  }
}
