import 'package:flutter/material.dart';

import '../../services/network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'primary_button.dart';

/// Estado vacío: ícono, título y texto de ayuda opcional, con una acción opcional.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.actionLabel, this.onAction});

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: AppColors.infoBg, shape: BoxShape.circle),
              child: Icon(icon, size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message!, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error con mensaje claro y botón «Reintentar».
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final e = ApiException.from(error);
    return EmptyState(
      icon: e.isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: e.isNetwork ? 'Sin conexión' : 'Algo salió mal',
      message: e.message,
      actionLabel: 'Reintentar',
      onAction: onRetry,
    );
  }
}

/// Carga con recuadros que pulsan (shimmer propio, sin dependencias).
class LoadingState extends StatefulWidget {
  const LoadingState({super.key, this.items = 4, this.itemHeight = 76});

  final int items;
  final double itemHeight;

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cargando',
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_c),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.screen),
          itemCount: widget.items,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, _) => Container(
            height: widget.itemHeight,
            decoration: BoxDecoration(color: AppColors.chipInactive, borderRadius: AppRadius.cardAll),
          ),
        ),
      ),
    );
  }
}
