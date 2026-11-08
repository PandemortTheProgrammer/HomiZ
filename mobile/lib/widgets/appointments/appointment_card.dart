import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/status_badge.dart';
import '../../models/appointment.dart';

/// Tarjeta blanca con borde: «Jue - 22 Oct 5:00 pm» en negrita, la propiedad debajo y el estado a la derecha.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment, this.onTap});

  final Appointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardAll,
        side: const BorderSide(color: AppColors.divider),
      ),
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
                    Text(Fmt.appointment(appointment.scheduledAt), style: AppTextStyles.cardTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(appointment.property.name, style: AppTextStyles.secondary.copyWith(fontSize: 13)),
                    // Solo el personal recibe el cliente.
                    if (appointment.client != null) Text(appointment.client!.name, style: AppTextStyles.label),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              StatusBadge.fromStatus(appointment.status),
            ],
          ),
        ),
      ),
    );
  }
}
