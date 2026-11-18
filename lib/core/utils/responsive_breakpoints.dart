import 'package:flutter/material.dart';

/// Puntos de corte estándar para adaptación responsiva en ColimaNight
/// Cumplen con Material Design 3 Adaptability y estándares de redes sociales modernas.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Pantallas compactas (Smartphones en vertical): < 600 dp
  static const double compactMax = 600.0;

  /// Pantallas medianas (Tablets en vertical / Foldables): 600 dp a 849 dp
  static const double mediumMax = 850.0;

  /// Pantallas expandidas (Tablets en horizontal / Laptops): 850 dp a 1199 dp
  static const double expandedMax = 1200.0;

  /// Ancho máximo ergonómico para lectura y feed de una columna
  static const double maxFeedWidth = 780.0;

  /// Ancho máximo para modales y cuadros de diálogo en escritorio
  static const double maxModalWidth = 520.0;

  /// Ancho del panel lateral en pantallas de escritorio para el mapa
  static const double desktopSidebarWidth = 420.0;

  /// Determina si la pantalla actual es un smartphone compacto
  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compactMax;
  }

  /// Determina si la pantalla actual es una tablet o pantalla mediana
  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compactMax && width < mediumMax;
  }

  /// Determina si la pantalla actual es escritorio, web en PC o tablet horizontal
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= mediumMax;
  }

  /// Determina si la pantalla es muy estrecha (ej. iPhone SE 1st gen, Galaxy A-series < 360 dp)
  static bool isExtraSmall(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 360.0;
  }

  /// Retorna un padding horizontal adaptativo según el ancho de pantalla
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) {
      return const EdgeInsets.symmetric(horizontal: 10.0);
    } else if (width < compactMax) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (width < expandedMax) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    }
  }
}

/// Contenedor responsivo que centra y acota el contenido en pantallas medianas y grandes,
/// garantizando que las tarjetas y textos nunca se hiper-extiendan en PC o monitores panorámicos.
class ResponsiveContentContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContentContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxFeedWidth,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width <= maxWidth) {
      return padding != null ? Padding(padding: padding!, child: child) : child;
    }

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}

/// Adaptador Sliver para centrar slivers dentro de un CustomScrollView en escritorio
class ResponsiveSliverContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveSliverContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxFeedWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth <= maxWidth) {
      return SliverToBoxAdapter(child: child);
    }

    final horizontalMargin = (screenWidth - maxWidth) / 2;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      sliver: SliverToBoxAdapter(child: child),
    );
  }
}
