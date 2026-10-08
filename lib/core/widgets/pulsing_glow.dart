import 'package:flutter/material.dart';

/// Envuelve cualquier widget con un resplandor pulsante neón
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlur;
  final double minBlur;
  final Duration duration;
  final bool animateScale;

  const PulsingGlow({
    super.key,
    required this.child,
    required this.glowColor,
    this.maxBlur = 24.0,
    this.minBlur = 8.0,
    this.duration = const Duration(milliseconds: 1600),
    this.animateScale = true,
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: widget.minBlur,
      end: widget.maxBlur,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.animateScale ? 1.025 : 1.0,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.35 + (_controller.value * 0.25)),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: 2.0 + (_controller.value * 2.0),
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
