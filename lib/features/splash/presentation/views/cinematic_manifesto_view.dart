import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../venues/presentation/views/discovery_feed_view.dart';
import '../providers/manifesto_provider.dart';

/// Modelo de datos para cada escena narrativa del manifiesto cinematográfico
class _ManifestoScene {
  final String badge;
  final String title;
  final String narrativeText;
  final String footerNote;
  final IconData icon;
  final Color accentColor;

  const _ManifestoScene({
    required this.badge,
    required this.title,
    required this.narrativeText,
    required this.footerNote,
    required this.icon,
    required this.accentColor,
  });
}

/// Pantalla de Previsualización Cinematográfica (Manifiesto de Colima Night)
/// Explica con sinceridad y tono relajado el origen de la app, su dedicatoria
/// a la gente de Colima, y el compromiso de proteger las salidas nocturnas
/// frente a eventos decepcionantes o publicidad engañosa.
class CinematicManifestoView extends ConsumerStatefulWidget {
  final bool isManualReplay;

  const CinematicManifestoView({
    super.key,
    this.isManualReplay = false,
  });

  @override
  ConsumerState<CinematicManifestoView> createState() =>
      _CinematicManifestoViewState();
}

class _CinematicManifestoViewState extends ConsumerState<CinematicManifestoView>
    with SingleTickerProviderStateMixin {
  int _currentSceneIndex = 0;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Catálogo exacto de escenas aprobado por el creador
  static const List<_ManifestoScene> _scenes = [
    _ManifestoScene(
      badge: 'CARTA DEL CREADOR',
      title: 'El Origen & La Dedicatoria',
      narrativeText:
          'Colima Night nació en el silencio de una madrugada.\n\nDe mí, y desde mi soledad, hacia la gente verdaderamente excepcional de Colima que merece noches memorables.',
      footerNote: 'Dedicatoria personal • Colima & Villa de Álvarez',
      icon: Icons.nightlife_rounded,
      accentColor: AppColors.neonViolet,
    ),
    _ManifestoScene(
      badge: 'LA REALIDAD DE LA NOCHE',
      title: 'Evitando Noches Perdidas',
      narrativeText:
          'Todos hemos vivido esa noche donde la promesa de una fiesta épica —en un salón, un bar, un lugar especial— termina en decepción: lugares vacíos, mala atención y un ambiente diferente al que aspiraste.',
      footerNote: 'Frente a la publicidad inflada y expectativas vacías',
      icon: Icons.explore_off_rounded,
      accentColor: AppColors.neonAmber,
    ),
    _ManifestoScene(
      badge: 'EL RADAR HONESTO',
      title: 'Transparencia en Tiempo Real',
      narrativeText:
          'Esta plataforma existe para cuidar tu noche.\n\nNo es un directorio inflado ni trata de vender aforos falsos: Es el pulso real de la ciudad para saber exactamente cómo está el ambiente antes de que gastes tu tiempo y dinero.',
      footerNote: 'Aforos físicos reales, música en vivo y accesos verificados',
      icon: Icons.sensors_rounded,
      accentColor: AppColors.neonCyan,
    ),
    _ManifestoScene(
      badge: 'ASISTENCIA A LA APP',
      title: 'El Pulso Colectivo',
      narrativeText:
          'Colima Night cobra vida gracias a ti: Mientras más comunidad se sume, mejor y más precisa será nuestra brújula para saber exactamente cómo está el aforo esta noche. Conéctate y ayúdanos a mostrar la información más precisa del ambiente.',
      footerNote: 'Telemetría comunitaria y presencia física en tiempo real',
      icon: Icons.cell_tower_rounded,
      accentColor: AppColors.neonGreen,
    ),
    _ManifestoScene(
      badge: 'NUESTRA COMUNIDAD',
      title: 'Cuidar Cada Salida Juntos',
      narrativeText:
          'Hecho con el corazón, espero y te sirva, ya sea para proteger nuestras salidas o construir entre todos, una comunidad que nunca vuelva a perder una noche.\n\nBienvenidos a Colima Night.',
      footerNote: 'La noche real de Colima en la palma de tu mano',
      icon: Icons.favorite_rounded,
      accentColor: AppColors.neonMagenta,
    ),
    _ManifestoScene(
      badge: 'EL FUTURO • EXPANSIÓN ESTATAL',
      title: 'Próximamente: Tecomán & Manzanillo',
      narrativeText:
          'Colima Night apenas comienza.\n\nConforme nuestra comunidad crezca y según la respuesta de ustedes, expandiremos este radar honesto hacia la costa y el puerto: Tecomán y Manzanillo.\n\nConstruyendo, paso a paso, la red de cobertura nocturna más confiable de todo el estado.',
      footerNote: 'Expansión gradual impulsada por la respuesta comunitaria',
      icon: Icons.waves_rounded,
      accentColor: AppColors.neonCyan,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    // Registrar reproducción si no es una re-apertura manual
    if (!widget.isManualReplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(manifestoViewCountProvider.notifier).recordView();
      });
    }
  }

  void _nextScene() {
    if (_currentSceneIndex < _scenes.length - 1) {
      setState(() {
        _currentSceneIndex++;
      });
    } else {
      _enterApp();
    }
  }

  void _previousScene() {
    if (_currentSceneIndex > 0) {
      setState(() {
        _currentSceneIndex--;
      });
    }
  }

  void _enterApp() {
    if (widget.isManualReplay) {
      Navigator.of(context).pop();
    } else {
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
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentScene = _scenes[_currentSceneIndex];
    final isLastScene = _currentSceneIndex == _scenes.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF06070B),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _nextScene,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Fondo Atmosférico Cinematográfico con Auras Neón
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        _currentSceneIndex == 0 ? -0.4 : (_currentSceneIndex == 2 ? 0.4 : 0.0),
                        -0.2,
                      ),
                      radius: 1.1,
                      colors: [
                        currentScene.accentColor.withOpacity(
                          0.15 + (_glowAnimation.value * 0.12),
                        ),
                        const Color(0xFF100B1E),
                        const Color(0xFF06070B),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                );
              },
            ),

            // 2. Viñeta Cinematográfica (Letterbox anamórfico sutil)
            Column(
              children: [
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    border: Border(
                      bottom: BorderSide(
                        color: currentScene.accentColor.withOpacity(0.25),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    border: Border(
                      top: BorderSide(
                        color: currentScene.accentColor.withOpacity(0.25),
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 3. Contenido Principal Flotante
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Barra Superior con Indicadores de Capítulo y Botón Saltar
                    Row(
                      children: [
                        // Indicador de Progreso por Escenas (Estilo Cine)
                        Expanded(
                          child: Row(
                            children: List.generate(_scenes.length, (index) {
                              final isCurrent = index == _currentSceneIndex;
                              final isPassed = index < _currentSceneIndex;
                              return Expanded(
                                child: Container(
                                  height: 3,
                                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: isPassed
                                        ? currentScene.accentColor
                                        : (isCurrent
                                            ? Colors.white
                                            : Colors.white24),
                                    boxShadow: isCurrent
                                        ? [
                                            BoxShadow(
                                              color: currentScene.accentColor,
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Botón Saltar / Cerrar
                        GestureDetector(
                          onTap: _enterApp,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.20),
                                width: 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.isManualReplay ? 'Cerrar' : 'Saltar',
                                  style: AppTypography.badgeLabel.copyWith(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  widget.isManualReplay
                                      ? Icons.close_rounded
                                      : Icons.arrow_forward_ios_rounded,
                                  size: 10,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Escena Narrativa con Transición Suave (AnimatedSwitcher)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 550),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_currentSceneIndex),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge Neón del Capítulo
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: currentScene.accentColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: currentScene.accentColor.withOpacity(0.5),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    currentScene.icon,
                                    size: 14,
                                    color: currentScene.accentColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_currentSceneIndex + 1}/${_scenes.length} • ${currentScene.badge}',
                                    style: AppTypography.badgeLabel.copyWith(
                                      color: currentScene.accentColor,
                                      fontSize: 10,
                                      letterSpacing: 1.6,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Título de la Escena
                            Text(
                              currentScene.title,
                              style: AppTypography.heroDisplay.copyWith(
                                fontSize: 24,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: currentScene.accentColor.withOpacity(0.55),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Texto Narrativo Principal
                            Container(
                              padding: const EdgeInsets.only(left: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: currentScene.accentColor.withOpacity(0.7),
                                    width: 2.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                currentScene.narrativeText,
                                style: GoogleFonts.outfit(
                                  fontSize: 16.5,
                                  height: 1.65,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFE8E9F3),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Nota al pie sutil
                            Text(
                              currentScene.footerNote,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Barra Inferior de Navegación y Llamado a la Acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón Anterior (si no está en la primera escena)
                        if (_currentSceneIndex > 0)
                          GestureDetector(
                            onTap: _previousScene,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 14,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 40),

                        // Indicador interactivo "Toca para continuar"
                        if (!isLastScene)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Toca la pantalla para avanzar',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white54,
                                  fontSize: 11.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Colors.white38,
                              ),
                            ],
                          )
                        else
                          // Botón Prominente en la Escena Final
                          Expanded(
                            child: GestureDetector(
                              onTap: _enterApp,
                              child: Container(
                                margin: const EdgeInsets.only(left: 12),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neonViolet.withOpacity(0.65),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'ENTRAR A COLIMA NIGHT',
                                        style: AppTypography.bodyBold.copyWith(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          letterSpacing: 1.8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.nightlife_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        if (!isLastScene)
                          GestureDetector(
                            onTap: _nextScene,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: currentScene.accentColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: currentScene.accentColor.withOpacity(0.5),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: currentScene.accentColor,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
