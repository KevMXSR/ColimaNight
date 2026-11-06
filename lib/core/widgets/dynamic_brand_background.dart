import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tipos de fondo dinámico oficial para ColimaNight
enum BrandBackgroundType {
  /// Fondo con el Logotipo Oficial Primario ("Tropical Lounge & Coctelería de Autor")
  primaryLogo,

  /// Fondo con el mapa neón cartográfico de Colima ("colima_neon_map_bg.png")
  neonMapSecondary,
}

/// Fondo dinámico con atmósfera neón y respiración sutil para ColimaNight.
/// Preserva de forma íntegra el activo oficial de marca seleccionado,
/// asegurando contraste perfecto y legibilidad de textos mediante viñeta de absorción,
/// y optimizado con [RepaintBoundary] para mantener 60/120 FPS sin penalizar la batería.
class DynamicBrandBackground extends StatefulWidget {
  final Widget child;
  final BrandBackgroundType type;
  final double opacity;
  final bool enableBreathing;
  final Duration breathingDuration;

  const DynamicBrandBackground({
    super.key,
    required this.child,
    this.type = BrandBackgroundType.primaryLogo,
    this.opacity = 0.16,
    this.enableBreathing = true,
    this.breathingDuration = const Duration(milliseconds: 5500),
  });

  @override
  State<DynamicBrandBackground> createState() => _DynamicBrandBackgroundState();
}

class _DynamicBrandBackgroundState extends State<DynamicBrandBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.breathingDuration,
    );

    if (widget.enableBreathing) {
      _controller.repeat(reverse: true);
    }

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _assetPath {
    switch (widget.type) {
      case BrandBackgroundType.primaryLogo:
        return 'assets/images/logo_colimanight_primary.png';
      case BrandBackgroundType.neonMapSecondary:
        return 'assets/images/colima_neon_map_bg.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // CAPA 1: Fondo Dinámico Aislado con RepaintBoundary para Cero Repaint de Slivers
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = widget.enableBreathing ? _scaleAnimation.value : 1.0;
              final glowMultiplier = widget.enableBreathing ? _glowAnimation.value : 1.0;

              return Container(
                color: const Color(0xFF06070B),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Auras de luz ambiental neón difusa
                    Positioned(
                      top: -120,
                      left: -80,
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonCyan.withOpacity(0.09 * glowMultiplier),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140,
                      right: -100,
                      child: Container(
                        width: 380,
                        height: 380,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonMagenta.withOpacity(0.08 * glowMultiplier),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      left: 40,
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonViolet.withOpacity(0.08 * glowMultiplier),
                        ),
                      ),
                    ),

                    // Cuadrícula geométrica sutil (estética nocturna)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SubtleGridPainter(),
                      ),
                    ),

                    // Activo de Marca Oficial con Respiración Escalar y Opacidad Calibrada
                    Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: (widget.opacity * glowMultiplier).clamp(0.05, 0.40),
                          child: widget.type == BrandBackgroundType.primaryLogo
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 120),
                                  child: Image.asset(
                                    _assetPath,
                                    width: 380,
                                    height: 380,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const SizedBox.shrink(),
                                  ),
                                )
                              : Image.asset(
                                  _assetPath,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox.shrink(),
                                ),
                        ),
                      ),
                    ),

                    // Viñeta Gradual Superior e Inferior para Máxima Legibilidad de Textos y Tarjetas
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xD906070B), // 85% opaco arriba para despejar status bar y header
                              Color(0x3306070B), // Centro más abierto para vislumbrar el isotipo neón
                              Color(0xB306070B), // 70% opaco hacia abajo
                              Color(0xF506070B), // 96% opaco al fondo para lista y botones
                            ],
                            stops: [0.0, 0.35, 0.70, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // CAPA 2: Contenido en Primer Plano (Feed, Búsqueda, Tarjetas, Modales)
        widget.child,
      ],
    );
  }
}

/// Pintor de cuadrícula geométrica fina para textura cyber-night
class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1.0;

    const double step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
