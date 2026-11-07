import 'package:flutter/material.dart';

/// Colores de Homiz. Ninguna pantalla define colores sueltos: todo sale de aquí.
abstract final class AppColors {
  // Marca
  static const primary = Color(0xFF037DFF); // botones, tab activo, chips activos, enlaces
  static const primaryCard = Color(0xFF1D81EC); // tarjetas del panel de inicio

  /// Fondo de las pantallas de acceso: degradado vertical.
  static const authGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0377F4), Color(0xFF024AA2), Color(0xFF00235D)],
    stops: [0, 0.5, 1],
  );

  // Texto
  static const textPrimary = Color(0xFF131214);
  static const textSecondary = Color(0xFF2F2F2F);
  static const textMuted = Color(0xFF888888);
  static const sectionTitle = Color(0xFF285193); // «Mi propiedad», «Información»

  // Superficies
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFFFFFFF);
  static const inputFill = Color(0xFFF2F2F7);
  static const chipInactive = Color(0xFFF2F2F7);
  static const chipInactiveAlt = Color(0xFFEDEDED);
  static const divider = Color(0xFFD2D2D2);

  /// Tarjetas de listas (expediente, pagarés, recibos, reportes) con texto blanco encima.
  /// Token pensado para cambiarse fácilmente si se ajusta el diseño.
  static const cardNeutral = Color(0xFFA4A4A4);
  static const placeholderBox = Color(0xFFD9D9D9); // cuadros de fotos vacías

  // Estados
  static const success = Color(0xFF34C759); // Confirmada
  static const badgePaid = Color(0xFF41EF9E); // Pagado / Resuelto / Ver (texto oscuro)
  static const badgePending = Color(0xFFFEDC01); // Pendiente / En reparación (texto oscuro)
  static const danger = Color(0xFFDB2626);
  static const dangerBg = Color(0xFFFFE8E8);
  static const infoBg = Color(0xFFDBEBFF);
  static const notice = Color(0xFF3629B7); // ícono del aviso informativo

  // Avatar con iniciales
  static const avatarBg = Color(0xFFDBEBFF);
  static const avatarText = Color(0xFF037DFF);

  // Barra inferior
  static const navActiveDot = Color(0xFFDB2626);
  static const navIcon = Color(0xFF131214);
  static const navIconInactive = Color(0xFF888888);

  // Sombras
  static const shadow = Color(0x14000000); // opacidad 0.08
}
