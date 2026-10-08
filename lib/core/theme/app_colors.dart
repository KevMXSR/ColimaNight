import 'package:flutter/material.dart';

/// Paleta de colores "Cyber-Night / Neon Clubbing" para ColimaNight
/// Orientada a usuarios jóvenes (18-35 años) con estética dark mode y contrastes fluorescentes.
class AppColors {
  AppColors._();

  // Fondos Principales (Dark Mode Profundo)
  static const Color background = Color(0xFF0A0A0F); // Negro obsidiana espacial
  static const Color surface = Color(0xFF13131F);    // Superficie oscura secundaria
  static const Color surfaceElevated = Color(0xFF1B1B2C); // Elevación con matiz violeta sutil

  // Acentos Neón Principales
  static const Color neonViolet = Color(0xFF8A2BE2); // Morado neón electrizante (Marca primaria)
  static const Color neonCyan = Color(0xFF00F0FF);   // Cyan ciberpunk / Energía activa
  static const Color neonMagenta = Color(0xFFFF007F);// Magenta disco / Highlights
  static const Color neonAmber = Color(0xFFFFB800);  // Ámbar / Dorado VIP & Status
  static const Color neonRedAlert = Color(0xFFFF3366); // Rojo neón para aforo 85%+ / Alertas en vivo
  static const Color neonGreen = Color(0xFF00FF88);   // Verde neón para disponible / 2x1 activo

  // Gradientes de Marca
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonViolet, neonMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanVioletGradient = LinearGradient(
    colors: [neonCyan, neonViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hotFireGradient = LinearGradient(
    colors: [Color(0xFFFF3366), Color(0xFFFF8800), neonAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism (Fondos translúcidos y bordes reflectantes)
  static const Color glassFill = Color(0x18FFFFFF);         // 9% Blanco difuminado
  static const Color glassFillElevated = Color(0x24FFFFFF); // 14% Blanco
  static const Color glassBorder = Color(0x33FFFFFF);       // 20% Borde cristalino
  static const Color glassBorderAccent = Color(0x6600F0FF); // Borde cyan reactivo

  // Textos y Contenidos
  static const Color textPrimary = Color(0xFFF8F9FD);   // Blanco nítido
  static const Color textSecondary = Color(0xFFA5A6BA); // Gris suave legible
  static const Color textMuted = Color(0xFF6B6C82);     // Texto secundario discreto

  // Sombras y Resplandores (Glow Effects)
  static BoxShadow neonVioletGlow({double blur = 16, double spread = 1}) {
    return BoxShadow(
      color: neonViolet.withOpacity(0.45),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }

  static BoxShadow neonCyanGlow({double blur = 14, double spread = 1}) {
    return BoxShadow(
      color: neonCyan.withOpacity(0.4),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }

  static BoxShadow hotRightNowGlow({double blur = 20, double spread = 2}) {
    return BoxShadow(
      color: neonMagenta.withOpacity(0.5),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }
}
