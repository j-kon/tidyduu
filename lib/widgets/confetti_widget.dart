import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final Duration duration;
  const ConfettiWidget({super.key, this.duration = const Duration(seconds: 3)});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Initialize particles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 80; i++) {
        _particles.add(
          ConfettiParticle(
            x: _random.nextDouble() * size.width,
            y: -_random.nextDouble() * 200, // start above screen
            vx: (_random.nextDouble() - 0.5) * 4.0, // horizontal velocity
            vy: _random.nextDouble() * 4.0 + 3.0, // vertical falling velocity
            color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
            rotation: _random.nextDouble() * pi * 2,
            rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
            width: _random.nextDouble() * 8 + 6,
            height: _random.nextDouble() * 12 + 8,
            shape: _random.nextBool()
                ? ParticleShape.rectangle
                : ParticleShape.circle,
          ),
        );
      }
      _controller.forward();
    });

    _controller.addListener(() {
      setState(() {
        for (var p in _particles) {
          p.update();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfettiPainter(_particles, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

enum ParticleShape { rectangle, circle }

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double rotation;
  double rotationSpeed;
  double width;
  double height;
  ParticleShape shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.width,
    required this.height,
    required this.shape,
  });

  void update() {
    x += vx;
    y += vy;
    rotation += rotationSpeed;
    // Add simple wind/gravity adjustments
    vy += 0.05; // gravity
    vx *= 0.98; // horizontal friction
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Fade out particles near the end of the animation
    final double opacity = progress > 0.8 ? (1.0 - progress) / 0.2 : 1.0;

    for (var p in particles) {
      if (p.y > size.height || p.x < 0 || p.x > size.width) continue;

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.shape == ParticleShape.rectangle) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.width,
            height: p.height,
          ),
          paint,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: p.width, height: p.width),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
