import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografía Poppins (google_fonts). En pruebas se desactiva la descarga de fuentes.
abstract final class AppFonts {
  static bool useGoogleFonts = true;

  static TextStyle poppins(TextStyle style) => useGoogleFonts ? GoogleFonts.poppins(textStyle: style) : style.copyWith(fontFamily: 'Poppins');
}

abstract final class AppTextStyles {
  /// «Homiz» en las pantallas de acceso.
  static TextStyle get brand => AppFonts.poppins(const TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: Colors.white, height: 1.05));

  /// Títulos grandes sobre el degradado («Iniciar sesión», «Crea tu cuenta»).
  static TextStyle get authTitle => AppFonts.poppins(const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white));

  /// Saludo «Hola, nombre».
  static TextStyle get greeting => AppFonts.poppins(const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  /// Título grande de detalle («Cita - Casa Las Palmas»).
  static TextStyle get pageTitle => AppFonts.poppins(const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  /// Subtítulo de sección («Mi propiedad», «Información»).
  static TextStyle get sectionTitle => AppFonts.poppins(const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.sectionTitle));

  static TextStyle get cardTitle => AppFonts.poppins(const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  static TextStyle get body => AppFonts.poppins(const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary));

  static TextStyle get secondary => AppFonts.poppins(const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted));

  static TextStyle get label => AppFonts.poppins(const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary));

  static TextStyle get button => AppFonts.poppins(const TextStyle(fontSize: 15, fontWeight: FontWeight.w600));

  static TextStyle get badge => AppFonts.poppins(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  static TextStyle get small => AppFonts.poppins(const TextStyle(fontSize: 10, fontWeight: FontWeight.w600));
}
