import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/models/venue_location.dart';

/// Generador de marcadores BitmapDescriptor personalizados usando el Canvas de Flutter
/// para Renderizado de alta definición (Retina/OLED) con resplandor neón dinámico.
class CustomMarkerPainter {
  CustomMarkerPainter._();

  /// Convierte un VenueLocation en una imagen en memoria apta para marcadores de mapa
  static Future<ui.Image> createVenuePinImage({
    required VenueStatus status,
    required String venueName,
    int? occupancyPercentage,
    double size = 130.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Color primaryColor = _getStatusColor(status);
    final Color glowColor = primaryColor.withValues(alpha: 0.45);
    final double centerX = size / 2;
    final double centerY = size / 2 - 12;
    final double headRadius = size * 0.32;

    // 1. Resplandor exterior Neón (Glow Effect)
    final Paint glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawCircle(Offset(centerX, centerY), headRadius + 6, glowPaint);

    // 2. Sombra del Pin
    final Path shadowPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(centerX, size - 8),
        width: size * 0.35,
        height: 10,
      ));
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(shadowPath, shadowPaint);

    // 3. Puntero inferior del Pin (Gota de ubicación)
    final Path pinPath = Path();
    pinPath.moveTo(centerX - 10, centerY + headRadius - 4);
    pinPath.lineTo(centerX, size - 14);
    pinPath.lineTo(centerX + 10, centerY + headRadius - 4);
    pinPath.close();

    final Paint pointerPaint = Paint()
      ..color = const Color(0xFF161B22)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, pointerPaint);

    final Paint pointerBorder = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(pinPath, pointerBorder);

    // 4. Cuerpo central del Pin (Círculo oscuro)
    final Paint bodyPaint = Paint()
      ..color = const Color(0xFF161B22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), headRadius, bodyPaint);

    // 5. Borde Neón Luminoso
    final Paint borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(Offset(centerX, centerY), headRadius, borderPaint);

    // 6. Icono central o Letra de Identificación
    final IconData icon = _getStatusIcon(status);
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.28,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, centerY - textPainter.height / 2),
    );

    // 7. Badge de aforo (si aplica)
    if (occupancyPercentage != null && occupancyPercentage > 0) {
      final double badgeX = centerX + headRadius * 0.72;
      final double badgeY = centerY - headRadius * 0.72;
      final double badgeRadius = 16.0;

      final Paint badgeBgPaint = Paint()..color = const Color(0xFF0D1117);
      final Paint badgeBorderPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(Offset(badgeX, badgeY), badgeRadius, badgeBgPaint);
      canvas.drawCircle(Offset(badgeX, badgeY), badgeRadius, badgeBorderPaint);

      final TextPainter badgePainter = TextPainter(textDirection: TextDirection.ltr);
      badgePainter.text = TextSpan(
        text: '$occupancyPercentage%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      );
      badgePainter.layout();
      badgePainter.paint(
        canvas,
        Offset(badgeX - badgePainter.width / 2, badgeY - badgePainter.height / 2),
      );
    }

    final ui.Picture picture = pictureRecorder.endRecording();
    return picture.toImage(size.toInt(), size.toInt());
  }

  /// Genera un marcador visual de Clúster (Agrupación de varios antros cercanos)
  static Future<ui.Image> createClusterPinImage({
    required int count,
    double size = 110.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final double center = size / 2;
    const Color clusterColor = Color(0xFF00E5FF); // Neon Cyan

    // Glow
    final Paint glowPaint = Paint()
      ..color = clusterColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawCircle(Offset(center, center), size * 0.38, glowPaint);

    // Fondo oscuro con degradado visual
    final Paint bodyPaint = Paint()
      ..color = const Color(0xFF0A0F1D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center, center), size * 0.36, bodyPaint);

    // Anillo exterior
    final Paint borderPaint = Paint()
      ..color = clusterColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(Offset(center, center), size * 0.36, borderPaint);

    // Conteo en el centro
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: count > 99 ? '99+' : count.toString(),
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center - textPainter.width / 2, center - textPainter.height / 2),
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    return picture.toImage(size.toInt(), size.toInt());
  }

  static Color _getStatusColor(VenueStatus status) {
    switch (status) {
      case VenueStatus.available:
        return const Color(0xFF00E676); // Verde Neón
      case VenueStatus.crowded:
        return const Color(0xFFFFD600); // Amarillo Neón
      case VenueStatus.specialEvent:
        return const Color(0xFFD500F9); // Violeta Neón
      case VenueStatus.alert:
        return const Color(0xFFFF1744); // Rojo Alerta Neón
      case VenueStatus.memorial:
        return const Color(0xFFB0BEC5); // Ghost Silver / Platinum
    }
  }

  static IconData _getStatusIcon(VenueStatus status) {
    switch (status) {
      case VenueStatus.available:
        return Icons.local_bar_rounded;
      case VenueStatus.crowded:
        return Icons.groups_rounded;
      case VenueStatus.specialEvent:
        return Icons.star_rounded;
      case VenueStatus.alert:
        return Icons.warning_amber_rounded;
      case VenueStatus.memorial:
        return Icons.favorite_rounded;
    }
  }
}
