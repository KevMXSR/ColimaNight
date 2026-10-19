import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../venues/presentation/views/discovery_feed_view.dart';

/// Pantalla de Carga (Splash Screen) cinemática para ColimaNight
/// Reproduce el video oficial de arranque en bucle suave / intro,
/// con respaldo visual neón y transición fluida al feed principal.
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
  Timer? _maxDurationTimer;
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

    _initializeVideoPlayer();

    // Temporizador de seguridad: si el usuario no interactúa o el video tarda,
    // navega suavemente al feed tras 4.5 segundos
    _maxDurationTimer = Timer(const Duration(milliseconds: 4500), () {
      _navigateToFeed();
    });
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final controller =
          VideoPlayerController.asset('assets/videos/splash_loading.mp4');
      _videoController = controller;
      await controller.initialize();
      if (!mounted) return;

      controller.setLooping(false);
      controller.setVolume(1.0);
      await controller.play();

      controller.addListener(() {
        if (!mounted) return;
        final position = controller.value.position;
        final duration = controller.value.duration;

        // Si el video llega al final, transicionar a la pantalla principal
        if (duration > Duration.zero && position >= duration && !_hasNavigated) {
          _navigateToFeed();
        }
      });

      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      // Fallback elegante en caso de que el entorno no soporte decodificación de video
      debugPrint('Video splash loading fallback: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _navigateToFeed() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _maxDurationTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
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
    _maxDurationTimer?.cancel();
    _pulseController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06070B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Capa 1: Video de Carga Oficial o Fallback Neón
          if (_isVideoInitialized && _videoController != null)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            // Fallback visual con aura neón mientras el video inicializa
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

          // Capa 2: Viñeta degradada superior e inferior para look cinematográfico
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.0, 0.2, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Capa 3: Barra superior con branding discreto y botón "Saltar"
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _navigateToFeed,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.45),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Saltar',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Capa 4: Barra inferior con indicador de carga y estatus
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          minHeight: 2.5,
                          backgroundColor: Color(0xFF1E1A2E),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.neonCyan,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sincronizando aforos y ambiente en vivo...',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white60,
                        fontSize: 11,
                        letterSpacing: 0.5,
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
