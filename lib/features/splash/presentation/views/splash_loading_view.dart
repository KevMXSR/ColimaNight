import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../venues/presentation/views/discovery_feed_view.dart';

/// Pantalla de Carga (Splash Screen) cinemática para ColimaNight
/// Reproduce a pantalla completa el video oficial de arranque (atractivo visual obligatorio),
/// asegurando reproducción automática sin bloqueos y transición fluida al feed.
class SplashLoadingView extends StatefulWidget {
  const SplashLoadingView({super.key});

  @override
  State<SplashLoadingView> createState() => _SplashLoadingViewState();
}

class _SplashLoadingViewState extends State<SplashLoadingView>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasNavigated = false;
  Timer? _safetyTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _startVideoPlayback();

    // Temporizador de respaldo: si por alguna razón el reproductor del sistema no responde,
    // se asegura el avance suave tras 12 segundos (el video dura 10s)
    _safetyTimer = Timer(const Duration(milliseconds: 12500), () {
      _navigateToFeed();
    });
  }

  Future<void> _startVideoPlayback() async {
    try {
      final controller =
          VideoPlayerController.asset('assets/videos/splash_loading.mp4');
      _videoController = controller;

      // 1. Inicializar el controlador
      await controller.initialize();
      if (!mounted) return;

      // 2. CRÍTICO PARA AUTOPLAY EN WEB Y DISPOSITIVOS:
      // El volumen en 0.0 activa el atributo 'muted' en el elemento HTML5/plataforma,
      // lo que garantiza que los navegadores (Chrome, Edge, Safari, móviles)
      // no bloqueen la reproducción automática (Autoplay Policy compliance).
      await controller.setVolume(0.0);
      await controller.setLooping(false);
      await controller.play();

      controller.addListener(_onVideoControllerUpdate);

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });

        // Sincronizar el temporizador con la duración real del video + un margen de 400ms
        final duration = controller.value.duration;
        if (duration > Duration.zero) {
          _safetyTimer?.cancel();
          _safetyTimer = Timer(duration + const Duration(milliseconds: 400), () {
            _navigateToFeed();
          });
        }
      }
    } catch (e) {
      debugPrint('Video splash initialization error: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _onVideoControllerUpdate() {
    if (!mounted || _hasNavigated) return;
    final controller = _videoController;
    if (controller == null) return;

    final val = controller.value;
    if (!val.isInitialized) return;

    if (!_isVideoInitialized && val.isPlaying) {
      setState(() => _isVideoInitialized = true);
    }

    final position = val.position;
    final duration = val.duration;

    // Cuando el video llega a su fin, transicionar automáticamente al feed principal
    if (duration > Duration.zero &&
        position >= duration - const Duration(milliseconds: 200)) {
      _navigateToFeed();
    }
  }

  void _navigateToFeed() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _safetyTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DiscoveryFeedView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _pulseController.dispose();
    _videoController?.removeListener(_onVideoControllerUpdate);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;
    final isPlayingVideo = _isVideoInitialized &&
        controller != null &&
        controller.value.isInitialized;

    return Scaffold(
      backgroundColor: const Color(0xFF06070B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Capa 1: Video Oficial a Pantalla Completa (Full Cover) o Fallback Neón
          if (isPlayingVideo)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width > 0
                      ? controller.value.size.width
                      : 1080,
                  height: controller.value.size.height > 0
                      ? controller.value.size.height
                      : 1920,
                  child: VideoPlayer(controller),
                ),
              ),
            )
          else
            // Fallback con aura neón mientras carga el video
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.1),
                  radius: 0.9,
                  colors: [
                    Color(0xFF1E103A),
                    Color(0xFF0E071A),
                    Color(0xFF06070B),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonViolet.withOpacity(
                                  0.45 + (_pulseAnimation.value * 0.35),
                                ),
                                blurRadius: 35 + (_pulseAnimation.value * 20),
                                spreadRadius: 4 + (_pulseAnimation.value * 8),
                              ),
                              BoxShadow(
                                color: AppColors.neonCyan.withOpacity(
                                  0.25 + (_pulseAnimation.value * 0.25),
                                ),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.nightlife_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'COLIMA NIGHT',
                      style: AppTypography.heroDisplay.copyWith(
                        letterSpacing: 6,
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            color: AppColors.neonCyan,
                            blurRadius: 18,
                          ),
                          const Shadow(
                            color: AppColors.neonViolet,
                            blurRadius: 24,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'LA GUÍA NOCTURNA DE COLIMA & VDA',
                      style: AppTypography.badgeLabel.copyWith(
                        letterSpacing: 2.5,
                        fontSize: 10,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Capa 2: Viñeta degradada sutil para realce visual cinematográfico
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.40),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                    stops: const [0.0, 0.15, 0.80, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Capa 3: Barra inferior con indicador de progreso neón sincronizado
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28, left: 32, right: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: AnimatedBuilder(
                          animation: controller ?? _pulseController,
                          builder: (context, _) {
                            double? progress;
                            if (controller != null &&
                                controller.value.isInitialized &&
                                controller.value.duration.inMilliseconds > 0) {
                              progress = (controller.value.position.inMilliseconds /
                                      controller.value.duration.inMilliseconds)
                                  .clamp(0.0, 1.0);
                            }
                            return LinearProgressIndicator(
                              value: progress,
                              minHeight: 2.5,
                              backgroundColor: const Color(0xFF1E1A2E),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.neonCyan,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'COLIMA NIGHT • EN VIVO',
                      style: AppTypography.badgeLabel.copyWith(
                        color: Colors.white70,
                        fontSize: 9.5,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
