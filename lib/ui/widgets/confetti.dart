import 'dart:math';

import 'package:flutter/material.dart';

/// Short burst of confetti and droplets, played whenever [trigger] changes.
class Confetti extends StatefulWidget {
  const Confetti({super.key, required this.trigger});

  final int trigger;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  List<_Piece> _pieces = const [];

  @override
  void didUpdateWidget(Confetti old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) {
      final r = Random();
      const colors = [
        Color(0xFF3A9BFF),
        Color(0xFF5ED3F3),
        Color(0xFFFFC94D),
        Color(0xFFFF7C98),
        Color(0xFF34C38F),
      ];
      _pieces = List.generate(
        44,
        (_) => _Piece(
          angle: -pi / 2 + (r.nextDouble() - 0.5) * pi * 0.9,
          speed: 0.55 + r.nextDouble() * 0.6,
          spin: (r.nextDouble() - 0.5) * 12,
          color: colors[r.nextInt(colors.length)],
          size: 5 + r.nextDouble() * 6,
          round: r.nextBool(),
        ),
      );
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ConfettiPainter(_c, _pieces),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.color,
    required this.size,
    required this.round,
  });

  final double angle;
  final double speed;
  final double spin;
  final Color color;
  final double size;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.anim, this.pieces) : super(repaint: anim);

  final Animation<double> anim;
  final List<_Piece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    if (t == 0 || t == 1) return;
    final origin = Offset(size.width / 2, size.height * 0.55);
    final fade = (1 - t).clamp(0.0, 1.0);
    for (final p in pieces) {
      final v = p.speed * size.height;
      final pos =
          origin +
          Offset(
            cos(p.angle) * v * t,
            sin(p.angle) * v * t + 0.9 * size.height * t * t,
          );
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.5,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.pieces != pieces;
}
