import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Pestañas en píldora (Resumen · Expediente · Pagos · Mantenimiento).
/// Activa: píldora azul con texto blanco; inactivas: gris claro con texto gris.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({super.key, required this.tabs, required this.selected, required this.onChanged});

  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.screenInsets,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            _Pill(label: tabs[i], active: i == selected, onTap: () => onChanged(i)),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: active ? AppColors.primary : AppColors.chipInactive,
        borderRadius: AppRadius.pillAll,
        child: InkWell(
          borderRadius: AppRadius.pillAll,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(color: active ? Colors.white : AppColors.textMuted, fontWeight: active ? FontWeight.w600 : FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selector de dos opciones en una píldora (Pagarés | Recibos, Reportes | Historial).
class PillToggle extends StatelessWidget {
  const PillToggle({super.key, required this.options, required this.selected, required this.onChanged});

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(color: AppColors.chipInactive, borderRadius: AppRadius.pillAll),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: Semantics(
                selected: i == selected,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selected ? AppColors.primary : Colors.transparent,
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Text(
                      options[i],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label.copyWith(color: i == selected ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
