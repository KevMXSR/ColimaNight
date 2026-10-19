import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

/// Componente unificado para renderizar imágenes de establecimientos en ColimaNight.
/// Soporta tanto referencias locales (assets) como URLs remotas (Unsplash / CDN)
/// con manejo de errores, placeholders neón y soporte para animaciones Hero.
class AppVenueImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppVenueImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.heroTag,
    this.placeholder,
    this.errorWidget,
  });

  bool get _isNetwork =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_isNetwork) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              color: AppColors.surfaceElevated,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.neonViolet,
                ),
              ),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              color: AppColors.surface,
              child: const Center(
                child: Icon(Icons.nightlife, color: AppColors.neonViolet, size: 36),
              ),
            ),
      );
    } else {
      imageWidget = Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              color: AppColors.surface,
              child: const Center(
                child: Icon(Icons.nightlife, color: AppColors.neonViolet, size: 36),
              ),
            ),
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
