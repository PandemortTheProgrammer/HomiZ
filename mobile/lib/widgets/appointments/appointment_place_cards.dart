import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/maps.dart';
import '../common/cards.dart';
import '../common/contact_actions.dart';
import '../../models/appointment.dart';

/// Ubicación de la cita. La dirección y el punto exactos llegan cuando la cita está confirmada;
/// antes solo se ve la zona (en el sitio web es una zona aproximada de ~3 km).
class AppointmentLocationCard extends StatelessWidget {
  const AppointmentLocationCard({super.key, required this.appointment});

  final Appointment appointment;

  /// Personal (broker o administración): siempre ve la dirección y el mapa para llegar.
  bool get _staff => appointment.client != null;

  @override
  Widget build(BuildContext context) {
    final p = appointment.property;
    final exact = p.exactLocation && (p.address ?? '').isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(exact ? Icons.place_rounded : Icons.lock_clock_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exact ? p.address! : (p.zone ?? 'Zona por confirmar'), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  _staff
                      ? 'Dirección de la casa. El cliente la ve en cuanto confirmas la cita.'
                      : exact
                      ? 'Ubicación exacta de tu visita.'
                      : 'La dirección exacta aparece aquí en cuanto tu asesor confirme la cita.',
                  style: AppTextStyles.secondary.copyWith(fontSize: 13),
                ),
                if (exact) ...[
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => openMap(context, lat: p.hasPoint ? p.lat : null, lng: p.hasPoint ? p.lng : null, address: p.address, label: p.name),
                    icon: const Icon(Icons.directions_outlined),
                    label: const Text('Cómo llegar'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tu asesor: el cliente lo puede llamar o escribirle (el contacto es mutuo).
class AppointmentAdvisorCard extends StatelessWidget {
  const AppointmentAdvisorCard({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final b = appointment.broker!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyValueRow(label: 'Nombre', value: b.name),
          KeyValueRow(label: 'Teléfono', value: b.phone ?? 'Sin registrar'),
          KeyValueRow(label: 'Correo', value: b.email ?? 'Sin registrar', showDivider: false),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ContactActions(phone: b.phone, email: b.email, subject: 'Mi visita a ${appointment.property.name} (${appointment.code})'),
          ),
        ],
      ),
    );
  }
}
