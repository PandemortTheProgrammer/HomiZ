import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Sección que se abre y se cierra al tocar su título, para que las pantallas largas no abrumen.
/// Cerrada muestra un [summary] de una línea con lo más importante (p. ej. «3 mensajes» o la zona).
class CollapsibleSection extends StatefulWidget {
  const CollapsibleSection({super.key, required this.title, required this.child, this.summary, this.initiallyOpen = false, this.compact = false});

  final String title;

  /// Resumen que se ve con la sección cerrada.
  final String? summary;
  final Widget child;
  final bool initiallyOpen;

  /// Título pequeño en mayúsculas (para grupos dentro de una tarjeta, como los del formulario).
  final bool compact;

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final titleStyle = widget.compact ? AppTextStyles.small.copyWith(color: AppColors.textMuted, letterSpacing: 0.6, fontSize: 11) : AppTextStyles.sectionTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          hint: _open ? 'Toca para ocultar' : 'Toca para ver',
          child: InkWell(
            borderRadius: AppRadius.cardAll,
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: widget.compact ? AppSpacing.sm : AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.compact ? widget.title.toUpperCase() : widget.title, style: titleStyle),
                        if (!_open && summary != null && summary.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(summary, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.secondary.copyWith(fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more_rounded, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
                  padding: EdgeInsets.only(bottom: widget.compact ? AppSpacing.sm : 0),
                  child: widget.child,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
