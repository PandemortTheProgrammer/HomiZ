import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// ThemeData claro de Homiz.
abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.danger,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
    );
    final t = base.textTheme.apply(bodyColor: AppColors.textSecondary, displayColor: AppColors.textPrimary);
    TextStyle? p(TextStyle? s) => s == null ? null : AppFonts.poppins(s);
    final textTheme = TextTheme(
      displayLarge: p(t.displayLarge),
      displayMedium: p(t.displayMedium),
      displaySmall: p(t.displaySmall),
      headlineLarge: p(t.headlineLarge),
      headlineMedium: p(t.headlineMedium),
      headlineSmall: p(t.headlineSmall),
      titleLarge: p(t.titleLarge),
      titleMedium: p(t.titleMedium),
      titleSmall: p(t.titleSmall),
      bodyLarge: p(t.bodyLarge),
      bodyMedium: p(t.bodyMedium),
      bodySmall: p(t.bodySmall),
      labelLarge: p(t.labelLarge),
      labelMedium: p(t.labelMedium),
      labelSmall: p(t.labelSmall),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.pageTitle,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        hintStyle: AppTextStyles.secondary.copyWith(fontSize: 14),
        border: OutlineInputBorder(borderRadius: AppRadius.inputAll, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.inputAll, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadius.inputAll, borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: AppRadius.inputAll, borderSide: const BorderSide(color: AppColors.danger)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: AppRadius.inputAll, borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
        errorStyle: AppTextStyles.secondary.copyWith(color: AppColors.danger),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
        titleTextStyle: AppTextStyles.cardTitle.copyWith(fontSize: 17),
        contentTextStyle: AppTextStyles.body,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card * 2))),
      ),
    );
  }
}
