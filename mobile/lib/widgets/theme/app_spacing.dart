import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Espaciados de la app.
abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  /// Padding horizontal de todas las pantallas.
  static const screen = 16.0;
  static const screenInsets = EdgeInsets.symmetric(horizontal: screen);

  /// Alto mínimo de controles táctiles.
  static const control = 48.0;
}

/// Radios: 12 en tarjetas, 10 en campos, píldora en botones, chips y badges.
abstract final class AppRadius {
  static const card = 12.0;
  static const input = 10.0;
  static const pill = 999.0;

  static final cardAll = BorderRadius.circular(card);
  static final inputAll = BorderRadius.circular(input);
  static final pillAll = BorderRadius.circular(pill);
}

/// Sombra suave (blur 8, opacidad 0.08).
abstract final class AppShadows {
  static const soft = [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))];
}
