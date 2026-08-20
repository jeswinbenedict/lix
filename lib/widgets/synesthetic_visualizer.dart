import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// High-performance synesthetic audio visualizer.
/// Renders fluid reactive frequency rings and dynamic orbital particles.
class SynestheticVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color primaryColor;
  final Color accentColor;
  final double size;

  const SynestheticVisualizer({
    super.key,
    this.isPlaying = true,
    this.primaryColor = AppTheme.primary,
    this.accentColor = const Color(0xFF06B6D4),
    this.size = 280,
  });

  @override
  State<SynestheticVisualizer> createState() => _SynestheticVisualizerState();
}

class _SynestheticVisualizerState extends State<SynestheticVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    for (int i = 0; i < 40; i++) {
      _particles.add(_createRandomParticle());
    }
  }

  _Particle _createRandomParticle() {
    final angle = _random.nextDouble() * 2 * pi;
    final distance = 40.0 + _random.nextDouble() * (widget.size * 0.4);
    final speed = 0.005 + _random.nextDouble() * 0.015;
    final radius = 1.5 + _random.nextDouble() * 3.5;
    final alpha = 100 + _random.nextInt(155);

    return _Particle(
      angle: angle,
      distance: distance,
      speed: speed,
      radius: radius,
      alpha: alpha,
    );
  }

  @override
  void didUpdateWidget(covariant SynestheticVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _VisualizerPainter(
              progress: _controller.value,
              isPlaying: widget.isPlaying,
              primaryColor: widget.primaryColor,
              accentColor: widget.accentColor,
              particles: _particles,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  double angle;
  double distance;
  double speed;
  double radius;
  int alpha;

  _Particle({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.radius,
    required this.alpha,
  });
}

class _VisualizerPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final Color primaryColor;
  final Color accentColor;
  final List<_Particle> particles;

  _VisualizerPainter({
    required this.progress,
    required this.isPlaying,
    required this.primaryColor,
    required this.accentColor,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.35;

    // 1. Ambient Central Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withAlpha(isPlaying ? 70 : 20),
          accentColor.withAlpha(isPlaying ? 35 : 10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.4));

    canvas.drawCircle(center, baseRadius * 1.4, glowPaint);

    // 2. Frequency Wave Rings (Harmonic Sinusoids)
    final ringCount = 3;
    for (int r = 0; r < ringCount; r++) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = SweepGradient(
          colors: [
            primaryColor.withAlpha(r == 0 ? 200 : 120),
            accentColor.withAlpha(r == 0 ? 200 : 120),
            primaryColor.withAlpha(r == 0 ? 200 : 120),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

      final path = Path();
      const numPoints = 80;
      final offsetAngle = (r * pi / 3) + (progress * 2 * pi * (r.isEven ? 1 : -1));

      for (int i = 0; i <= numPoints; i++) {
        final theta = (i / numPoints) * 2 * pi;
        final wave = isPlaying
            ? sin(theta * (6 + r * 2) + progress * 2 * pi * 2) * (5.0 + r * 3.0)
            : sin(theta * 4) * 2.0;

        final radius = (baseRadius + r * 14.0) + wave;
        final x = center.dx + radius * cos(theta + offsetAngle);
        final y = center.dy + radius * sin(theta + offsetAngle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, ringPaint);
    }

    // 3. Orbital Particles
    for (final p in particles) {
      if (isPlaying) {
        p.angle += p.speed;
      }
      final px = center.dx + p.distance * cos(p.angle);
      final py = center.dy + p.distance * sin(p.angle);

      final particlePaint = Paint()
        ..color = Color.lerp(primaryColor, accentColor, sin(p.angle).abs())!
            .withAlpha(isPlaying ? p.alpha : (p.alpha ~/ 3));

      canvas.drawCircle(Offset(px, py), p.radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter oldDelegate) => true;
}
