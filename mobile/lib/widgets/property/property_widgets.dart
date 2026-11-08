import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Foto grande con radio 12. Sin URL muestra el recuadro gris (las fotos se subirán después).
/// [overlay] se dibuja abajo, sobre una franja translúcida o como chip.
class PropertyHero extends StatelessWidget {
  const PropertyHero({super.key, this.url, this.height = 200, this.overlay, this.semanticLabel});

  final String? url;
  final double height;
  final Widget? overlay;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    const empty = ColoredBox(color: AppColors.placeholderBox);
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url == null)
                empty
              else
                CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover, placeholder: (_, _) => empty, errorWidget: (_, _, _) => empty),
              if (overlay != null) Positioned(left: 0, right: 0, bottom: 0, child: overlay!),
            ],
          ),
        ),
      ),
    );
  }
}

/// Franja translúcida inferior: nombre en blanco y debajo pin + ubicación.
class HeroCaption extends StatelessWidget {
  const HeroCaption({super.key, required this.title, this.location});

  final String title;
  final String? location;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.38),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontSize: 18)),
          if (location != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(location!, style: AppTextStyles.secondary.copyWith(color: Colors.white))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Chip translúcido con pin («Cancún») abajo a la izquierda de la foto.
class LocationChip extends StatelessWidget {
  const LocationChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: AppRadius.pillAll),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: Colors.white),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTextStyles.badge.copyWith(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Fila de características con íconos: «5 habitaciones», «3 baños», «Alberca».
class FeatureRow extends StatelessWidget {
  const FeatureRow({super.key, this.rec, this.banos, this.amenities = const []});

  final int? rec;
  final double? banos;
  final List<String> amenities;

  static String _num(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      if (rec != null) (Icons.bed_outlined, '$rec ${rec == 1 ? 'habitación' : 'habitaciones'}'),
      if (banos != null) (Icons.bathtub_outlined, '${_num(banos!)} ${banos == 1 ? 'baño' : 'baños'}'),
      for (final a in amenities.take(3)) (a.toLowerCase().contains('alberca') ? Icons.pool_outlined : Icons.check_circle_outline, a),
    ];
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (icon, text) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(text, style: AppTextStyles.label),
            ],
          ),
      ],
    );
  }
}
