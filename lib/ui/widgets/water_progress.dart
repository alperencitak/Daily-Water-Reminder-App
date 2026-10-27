import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Animated water surface filling a rounded tank up to [level] (0..1).
/// Only the painter repaints each frame; nothing is rebuilt.
class WaterFill extends StatefulWidget {
  const WaterFill({super.key, required this.level});

  final double level;

  @override
  State<WaterFill> createState() => _WaterFillState();
}

class _WaterFillState extends State<WaterFill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _WavePainter(
          level: widget.level,
          wave: _wave,
          front: c.waterFront,
          back: c.waterBack,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.level,
    required this.wave,
    required this.front,
    required this.back,
  }) : super(repaint: wave);

  final double level;
  final Animation<double> wave;
  final Color front;
  final Color back;

  @override
  void paint(Canvas canvas, Size size) {
    if (level <= 0) return;
    final phase = wave.value * 2 * pi;
    final top = size.height * (1 - level.clamp(0.0, 1.0));
    final amp = level >= 1 ? 3.0 : 9.0;
    canvas.drawPath(
      _wave(size, top + 4, amp, phase + pi * 0.8, 1.3),
      Paint()..color = back,
    );
    canvas.drawPath(
      _wave(size, top + 10, amp, phase, 1),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [front, Color.lerp(front, const Color(0xFF1F6FE5), 0.35)!],
        ).createShader(Rect.fromLTWH(0, top, size.width, size.height - top)),
    );
    // A few rising bubbles.
    final bubble = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (var i = 0; i < 6; i++) {
      final p = (wave.value + i / 6) % 1;
      final x = size.width * (0.12 + 0.15 * i) + sin(phase + i) * 6;
      final y = size.height - p * (size.height - top - 14);
      if (y > top + 18) {
        canvas.drawCircle(Offset(x, y), 2.5 + (i % 3) * 1.5, bubble);
      }
    }
  }

  Path _wave(Size size, double top, double amp, double shift, double freq) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width + 6; x += 6) {
      path.lineTo(x, top + sin(x / size.width * 2 * pi * freq + shift) * amp);
    }
    return path
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.level != level || old.front != front || old.back != back;
}
