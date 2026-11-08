import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum BadgeKind { pending, paid, resolved, inRepair, confirmed, view, overdue, cancelled, neutral }

/// Etiqueta de estado en píldora: Pendiente, Pagado, Resuelto, En reparación, Confirmada, Ver…
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.kind, this._label, this.onTap});

  /// Traduce los estados de la API (pagarés, recibos, mantenimiento y citas).
  factory StatusBadge.fromStatus(String status, {Key? key, VoidCallback? onTap}) {
    final (kind, label) = switch (status) {
      'pending' => (BadgeKind.pending, 'Pendiente'),
      'paid' => (BadgeKind.paid, 'Pagado'),
      'overdue' => (BadgeKind.overdue, 'Vencido'),
      'cancelled' => (BadgeKind.cancelled, 'Cancelado'),
      'reported' => (BadgeKind.pending, 'Reportado'),
      'in_review' => (BadgeKind.pending, 'En revisión'),
      'in_repair' => (BadgeKind.inRepair, 'En reparación'),
      'resolved' => (BadgeKind.resolved, 'Resuelto'),
      'por-confirmar' => (BadgeKind.pending, 'Por confirmar'),
      'confirmada' => (BadgeKind.confirmed, 'Confirmada'),
      'realizada' => (BadgeKind.neutral, 'Realizada'),
      'rechazada' => (BadgeKind.cancelled, 'Rechazada'),
      'cancelada' => (BadgeKind.cancelled, 'Cancelada'),
      _ => (BadgeKind.neutral, status),
    };
    return StatusBadge(key: key, kind: kind, label: label, onTap: onTap);
  }

  final BadgeKind kind;
  final String? _label;
  final VoidCallback? onTap;

  String get label =>
      _label ??
      switch (kind) {
        BadgeKind.pending => 'Pendiente',
        BadgeKind.paid => 'Pagado',
        BadgeKind.resolved => 'Resuelto',
        BadgeKind.inRepair => 'En reparación',
        BadgeKind.confirmed => 'Confirmada',
        BadgeKind.view => 'Ver',
        BadgeKind.overdue => 'Vencido',
        BadgeKind.cancelled => 'Cancelado',
        BadgeKind.neutral => '',
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      BadgeKind.pending || BadgeKind.inRepair => (AppColors.badgePending, AppColors.textPrimary),
      BadgeKind.paid || BadgeKind.resolved || BadgeKind.view => (AppColors.badgePaid, AppColors.textPrimary),
      BadgeKind.confirmed => (AppColors.success, Colors.white),
      BadgeKind.overdue => (AppColors.danger, Colors.white),
      BadgeKind.cancelled => (AppColors.dangerBg, AppColors.danger),
      BadgeKind.neutral => (AppColors.chipInactiveAlt, AppColors.textSecondary),
    };
    final badge = Container(
      constraints: BoxConstraints(minHeight: onTap != null ? 32 : 24),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pillAll),
      alignment: Alignment.center,
      child: Text(label, style: AppTextStyles.badge.copyWith(color: fg)),
    );
    if (onTap == null) return Semantics(label: label, child: ExcludeSemantics(child: badge));
    return Semantics(
      button: true,
      label: label,
      child: InkWell(borderRadius: AppRadius.pillAll, onTap: onTap, child: ExcludeSemantics(child: badge)),
    );
  }
}
