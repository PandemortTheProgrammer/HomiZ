import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Pide confirmación antes de una acción. Devuelve true solo si la persona acepta.
/// Título, mensaje y botones centrados, igual que las confirmaciones del sitio y del panel.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Aceptar',
  String cancelLabel = 'Cancelar',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(destructive ? Icons.delete_outline : Icons.help_outline, color: destructive ? AppColors.danger : AppColors.primary),
      title: Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 17), textAlign: TextAlign.center),
      content: Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelLabel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: destructive ? AppColors.danger : AppColors.primary),
          child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
  return result ?? false;
}
